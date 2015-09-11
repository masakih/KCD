/*
     File: CustomHTTPProtocol.m
 Abstract: An NSURLProtocol subclass that overrides the built-in HTTP/HTTPS protocol.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "CustomHTTPProtocol.h"

#import "CanonicalRequest.h"
#import "CacheStoragePolicy.h"

static BOOL kPreventOnDiskCaching = NO;

static NSArray *cachedExtensions = nil;
static NSDateFormatter *httpDateFormater = nil;

@interface CustomHTTPProtocol ()

@property (atomic, retain, readwrite) NSThread *                        clientThread;

@property (atomic, copy,   readwrite) NSArray *                         modes;              // see below
@property (atomic, assign, readwrite) NSTimeInterval                    startTime;          // written by client thread only, read by any thread
@property (atomic, retain, readwrite) NSURLRequest *                    actualRequest;      // client thread only
@property (atomic, retain, readwrite) NSURLConnection *                 connection;         // client thread only

// The concurrency control on .modes is too complex to explain in a short comment.  It's set up 
// on the client thread in -startLoading and then never modified.  It is, however, read by code 
// running on other threads (specifically the main thread), so we deallocate it in -dealloc 
// rather than in -stopLoading.  We can be sure that it's not read before it's set up because 
// the main thread code that reads it can only be called after -startLoading has started 
// the connection running.


@property (atomic, strong, readwrite) NSHTTPURLResponse *response;
@property (atomic, strong, readwrite) NSMutableData *data;
@property (atomic, readwrite) NSURLCacheStoragePolicy cachePolicy;

@end

@implementation CustomHTTPProtocol

@synthesize modes            = _modes;
@synthesize startTime        = _startTime;
@synthesize clientThread     = _clientThread;
@synthesize actualRequest    = _actualRequest;
@synthesize connection       = _connection;

#pragma mark * Subclass specific additions

static id<CustomHTTPProtocolDelegate> sDelegate;          // protected by @synchronized on the class

static NSURLCache *sMyURLCache = nil;

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSURLProtocol registerClass:self];
		
		cachedExtensions = @[@"swf", @"flv", @"png", @"jpg", @"jpeg", @"mp3"];
		
		
		httpDateFormater = [NSDateFormatter new];
		httpDateFormater.dateFormat = @"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz";
		httpDateFormater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	});
}

+ (NSURL *)cacheFileURL
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *path = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *bundleIdentifier = mainBundle.bundleIdentifier;
	path = [path URLByAppendingPathComponent:bundleIdentifier];
	path = [path URLByAppendingPathComponent:@"Caches"];
	return path;
}

+ (void)setupCache
{
	NSURL *path = [self cacheFileURL];
	NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:128 * 1024 * 1024
													  diskCapacity:1024 * 1024 * 1024
														  diskPath:path.path];
	sMyURLCache = cache;
}
+ (void)clearCache
{
	[sMyURLCache removeAllCachedResponses];
}

+ (void)start
    // See comment in header.
{
    [NSURLProtocol registerClass:self];
}

+ (id<CustomHTTPProtocolDelegate>)delegate
    // See comment in header.
{
    return sDelegate;
}

+ (void)setDelegate:(id<CustomHTTPProtocolDelegate>)newValue
    // See comment in header.
{
    @synchronized (self) {
        sDelegate = newValue;
    }
}

+ (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format, ...
    // All internal logging calls this routine, which routes the log message to the 
    // delegate.
{
    // protocol may be nil
    id<CustomHTTPProtocolDelegate> delegate;
    
    delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(customHTTPProtocol:logWithFormat:arguments:)]) {
        va_list ap;
        
        va_start(ap, format);
        [delegate customHTTPProtocol:protocol logWithFormat:format arguments:ap];
        va_end(ap);
    }
}

#pragma mark * NSURLProtocol overrides

static NSString * kOurRequestProperty = @"com.apple.dts.CustomHTTPProtocol";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
    // An override of an NSURLProtocol method.  We claim all HTTPS requests that don't have 
    // kOurRequestProperty attached.
    //
    // This can be called on any thread, so we have to be careful what we touch.
{
    BOOL        result;
    NSURL *     url;
    NSString *  scheme;
    
    url = [request URL];
    assert(url != nil);     // The code won't crash if url is nil, but we still want to know at debug time.
    
    result = ([self propertyForKey:kOurRequestProperty inRequest:request] == nil);
    if ( ! result ) {
        [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (recursive)", request];
    } else {
        scheme = [[url scheme] lowercaseString];
        assert(scheme != nil);
        
        result = [scheme isEqual:@"https"];

        // Flip the following to YES to have all requests go through the custom protocol.
        
        if ( ! result && /* NO */ YES) {
            result = [scheme isEqual:@"http"];
        }

        if ( ! result ) {
            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (scheme mismatch)", request];
        } else {
            [self customHTTPProtocol:nil logWithFormat:@"accept request %@", request];
        }
    }
    
    return result;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
    // An override of an NSURLProtocol method.   Canonicalising a request is quite complex, 
    // so all the heavy lifting has been shuffled off to a separate module.
    //
    // This can be called on any thread, so we have to be careful what we touch.
{
    NSURLRequest *      result;
    
    result = CanonicalRequestForRequest(request);

    [self customHTTPProtocol:nil logWithFormat:@"canonicalized %@ to %@", request, result];
    
    return result;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
    // An override of an NSURLProtocol method.   All we do here is log the call.
    //
    // This can be called on any thread, so we have to be careful what we touch.
{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self != nil) {
        [[self class] customHTTPProtocol:self logWithFormat:@"init for %@ from <%@ %p>", request, [client class], client];
	}
    return self;
}

static inline void useCache(NSCachedURLResponse *cache, CustomHTTPProtocol *object)
{
	NSData *data = cache.data;
	id<CustomHTTPProtocolDelegate> delegate = [CustomHTTPProtocol delegate];
	
	if([delegate respondsToSelector:@selector(customHTTPProtocol:didRecieveResponse:)]) {
		[delegate customHTTPProtocol:object didRecieveResponse:cache.response];
	}
	
	[[object client] URLProtocol:object didReceiveResponse:cache.response cacheStoragePolicy:NSURLCacheStorageAllowed];
	
	//
	if([delegate respondsToSelector:@selector(customHTTPProtocol:didRecieveData:)]) {
		[delegate customHTTPProtocol:object didRecieveData:data];
	}
	
	[[object client] URLProtocol:object didLoadData:data];
	
	//
	if([delegate respondsToSelector:@selector(customHTTPProtocolDidFinishLoading:)]) {
		[delegate customHTTPProtocolDidFinishLoading:object];
	}
	
	[[object client] URLProtocolDidFinishLoading:object];
}

- (void)startLoading
    // An override of an NSURLProtocol method.   At this point we kick off the process 
    // of loading the URL via NSURLConnection.
    //
    // The thread that this is called on becomes the client thread.
{
    NSMutableURLRequest *   newRequest;
    NSString *              currentMode;
    
    assert(self.clientThread == nil);           // you can't call -startLoading twice
    assert(self.connection == nil);

    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at 
    // you UIWebView!) we can be called from a non-standard thread which then runs a 
    // non-standard run loop mode waiting for the request to finish.  We detect this 
    // non-standard mode and add it to the list of run loop modes we use when scheduling 
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode" 
    // but it's better not to hard-code that here.
    
    assert(self.modes == nil);
    currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if ( [currentMode isEqual:NSDefaultRunLoopMode] ) {
        currentMode = nil;
    }
    self.modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, currentMode, nil];
    assert([self.modes count] > 0);

    // Create new request that's a clone of the request we were initialised with, 
    // except that it has our custom property set on it.
    
    newRequest = [[self request] mutableCopy];
    assert(newRequest != nil);
    
    [[self class] setProperty:[NSNumber numberWithBool:YES] forKey:kOurRequestProperty inRequest:newRequest];

    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    if (currentMode == nil) {
        [[self class] customHTTPProtocol:self logWithFormat:@"start %@", newRequest];
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"start %@ (mode %@)", newRequest, currentMode];
    }
	
	
	// Latch the actual request we sent down so that we can use it for cache storage
	// policy determination.
	
	self.actualRequest = newRequest;
	
	// Latch the thread we were called on, primarily for debugging purposes.
	
	self.clientThread = [NSThread currentThread];
	
    // Now create a connection with the new request.  Don't start it immediately because 
    // a) if we start immediately our delegate can be called before -initWithRequest:xxx 
    // returns, and that confuses our asserts, and b) we want to customise the run loop modes.
	
	
	NSURL *URL = self.actualRequest.URL;
	NSString *extension = [[URL path] pathExtension];
	if([cachedExtensions containsObject:extension]) {
//		NSLog(@"------> %@", self.actualRequest);
	}
	
	NSCachedURLResponse *cache = [sMyURLCache cachedResponseForRequest:self.actualRequest];
	if(cache) {
		NSDictionary *userInfo = cache.userInfo;
		if(userInfo) {
			NSDate *expiresDate = userInfo[@"Expires"];
//			NSLog(@"Expires -> %@", expiresDate);
			NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
			if([now compare:expiresDate] == NSOrderedAscending) {
//				NSLog(@"Ascending");
				useCache(cache, self);
//				NSLog(@"Use cache -> %@", self.request);
				return;
			}
		}
	}
	
    self.connection = [[NSURLConnection alloc] initWithRequest:newRequest delegate:self startImmediately:NO];
    assert(self.connection != nil);

    for (NSString * mode in self.modes) {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
    }
    
    // Once everything is ready to go, start the request.
    
    [self.connection start];
}

- (void)stopLoading
    // An override of an NSURLProtocol method.   We cancel our load.
    //
    // Expected to be called on the client thread.
{
    [[self class] customHTTPProtocol:self logWithFormat:@"stop (elapsed %.1f)", [NSDate timeIntervalSinceReferenceDate] - self.startTime];
    
    assert(self.clientThread != nil);           // someone must have called -startLoading

    // Check that we're being stopped on the same thread that we were started 
    // on.  Without this invariant things are going to go badly (for example, 
    // run loop sources that got attached during -startLoading may not get 
    // detached here).
    //
    // I originally had code here to skip over to the client thread but that 
    // actually gets complex when you consider run loop modes, so I've nixed it. 
    // Rather, I rely on our client calling us on the right thread, which is what 
    // the following assert is about.
    
    assert([NSThread currentThread] == self.clientThread);
    
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    self.actualRequest = nil;
    // Don't nil out self.modes; see the comment near the property declaration for a 
    // a discussion of this.
}


#pragma mark * NSURLConnection delegate callbacks

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
    // An NSURLConnection delegate callback.  We use this to tell the client about redirects 
    // (and for a bunch of debugging and logging).
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(request != nil);
    // response may be nil

    assert([NSThread currentThread] == self.clientThread);

    if (response == nil) {
        [[self class] customHTTPProtocol:self logWithFormat:@"will send request %@", request];
    } else {
        NSMutableURLRequest *    redirectRequest;

        // If response is not nil this is a redirect so we tell the client.

        [[self class] customHTTPProtocol:self logWithFormat:@"will send request %@ following redirect %@", request, response];

        // The new request was copied from our old request, so it has our magic property.  We actually 
        // have to remove that so that, when the client starts the new request, we see it.  If we 
        // don't do this then we never see the new request and thus don't get a chance to change 
        // its caching behaviour.
        //
        // We also cancel our current connection because the client is going to start a new request for 
        // us anyway.

        assert([[self class] propertyForKey:kOurRequestProperty inRequest:request] != nil);
        
        redirectRequest = [request mutableCopy];
        [[self class] removePropertyForKey:kOurRequestProperty inRequest:redirectRequest];
        
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
        
        [self.connection cancel];
        [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    }
    
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    NSURLCacheStoragePolicy cacheStoragePolicy;

    assert(connection == self.connection);
    assert(response != nil);

    assert([NSThread currentThread] == self.clientThread);

    // Pass the call on to our client.  The only tricky thing is that we have to decide on a 
    // cache storage policy, which is based on the actual request we issued, not the request 
    // we were given.
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.actualRequest, (NSHTTPURLResponse *) response);
    } else {
        assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
    }
	
    // If we're forcing in in-memory caching only, override the cache storage policy.
    
    if (kPreventOnDiskCaching) {
        if (cacheStoragePolicy == NSURLCacheStorageAllowed) {
            cacheStoragePolicy = NSURLCacheStorageAllowedInMemoryOnly;
        }
    }
	
	self.response = response;
	self.cachePolicy = cacheStoragePolicy;
	
	id<CustomHTTPProtocolDelegate> delegate = [[self class] delegate];
	if([delegate respondsToSelector:@selector(customHTTPProtocol:didRecieveResponse:)]) {
		[delegate customHTTPProtocol:self didRecieveResponse:response];
	}

    [[self class] customHTTPProtocol:self logWithFormat:@"received response %@ with cache storage policy %zu", response, (size_t) cacheStoragePolicy];
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(cachedResponse != nil);

    if (kPreventOnDiskCaching) {
        [[self class] customHTTPProtocol:self logWithFormat:@"will not cache response"];
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"will cache response"];
    }

    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(data != nil);

    assert([NSThread currentThread] == self.clientThread);

    // Just pass the call on to our client.

    if (NO) {
        [[self class] customHTTPProtocol:self logWithFormat:@"received %zu bytes of data", (size_t) [data length]];
    }
	
	if(self.cachePolicy == NSURLCacheStorageAllowed) {
		if(!self.data) {
			self.data = [NSMutableData data];
		}
		[self.data appendData:data];
	}
	
	
	id<CustomHTTPProtocolDelegate> delegate = [[self class] delegate];
	if([delegate respondsToSelector:@selector(customHTTPProtocol:didRecieveData:)]) {
		[delegate customHTTPProtocol:self didRecieveData:data];
	}
	
    [[self client] URLProtocol:self didLoadData:data];
}

- (NSDate *)expiresDate
{
	NSString *requestHeader = [[self.response allHeaderFields][@"Cache-Control"] lowercaseString];
	if(requestHeader != nil) {
		NSRange range = [requestHeader rangeOfString:@"max-age="];
		if(range.location != NSNotFound) {
			NSUInteger lastPos = NSMaxRange(range);
			NSString *ageString = [requestHeader substringFromIndex:lastPos];
			NSInteger age = ageString.integerValue;
			
			return [NSDate dateWithTimeIntervalSinceNow:age];
		}
	}
	
	requestHeader = [[self.response allHeaderFields][@"Expires"] lowercaseString];
	if(requestHeader != nil) {
		return [httpDateFormater dateFromString:requestHeader];
	}
	
	return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);

    assert([NSThread currentThread] == self.clientThread);

    [[self class] customHTTPProtocol:self logWithFormat:@"success"];
	
	if(self.cachePolicy == NSURLCacheStorageAllowed) {
		NSURL *URL = self.actualRequest.URL;
		NSString *extension = [[URL path] pathExtension];
		if([cachedExtensions containsObject:extension]) {
			NSDate *expiresDate = [self expiresDate];
			if(expiresDate) {
				NSCachedURLResponse *cache = [[NSCachedURLResponse alloc] initWithResponse:self.response
																					  data:self.data
																				  userInfo:@{ @"Expires" : expiresDate }
																			 storagePolicy:self.cachePolicy];
				[sMyURLCache storeCachedResponse:cache forRequest:self.actualRequest];
				
//				NSLog(@"Store cache -> %@", self.actualRequest);
			}
		}
	}
	
	id<CustomHTTPProtocolDelegate> delegate = [[self class] delegate];
	if([delegate respondsToSelector:@selector(customHTTPProtocolDidFinishLoading:)]) {
		[delegate customHTTPProtocolDidFinishLoading:self];
	}

    // Just pass the call on to our client.

    [[self client] URLProtocolDidFinishLoading:self];
    
    // We don't need to clean up the connection here; the system will call 
    // our -stopLoading for that.
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(error != nil);

    assert([NSThread currentThread] == self.clientThread);

    [[self class] customHTTPProtocol:self logWithFormat:@"error %@ / %d", [error domain], (int) [error code]];
	
	id<CustomHTTPProtocolDelegate> delegate = [[self class] delegate];
	if([delegate respondsToSelector:@selector(customHTTPProtocol:didFailWithError:)]) {
		[delegate customHTTPProtocol:self didFailWithError:error];
	}

    // Just pass the call on to our client.

    [[self client] URLProtocol:self didFailWithError:error];

    // We don't need to clean up the connection here; the system will call 
    // our -stopLoading for that.
}

@end
