//
//  HMHTTPProtocol.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/07.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMHTTPProtocol.h"

@class NSCFURLProtocol;

static Class cfURLProtocolClass = Nil;
static id semaphore = nil;
static BOOL inCreation = NO;

@interface HMHTTPProtocol ()
@property (retain) id origin;
@end

@implementation HMHTTPProtocol

//+ (void)load
//{
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		[NSURLProtocol registerClass:[self class]];
//		cfURLProtocolClass = NSClassFromString(@"NSCFURLProtocol");
//		semaphore = [NSObject new];
//	});
//}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
	self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
	if(self) {
//		@synchronized(semaphore) {
			inCreation = YES;
			_origin = [[cfURLProtocolClass alloc] initWithRequest:request cachedResponse:cachedResponse client:self];
			inCreation = NO;
		}
//	}
	
	return self;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	return !inCreation;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
	NSURLRequest *res = nil;
//	@synchronized(semaphore) {
		inCreation = YES;
		res = [cfURLProtocolClass canonicalRequestForRequest:request];
		inCreation = NO;
//	}
	return res;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
	BOOL res = NO;
//	@synchronized(semaphore) {
		inCreation = YES;
		res = [cfURLProtocolClass requestIsCacheEquivalent:a toRequest:b];
		inCreation = NO;
//	}
	return res;
}
- (void)startLoading
{
	[self.origin startLoading];
}
- (void)stopLoading
{
	[self.origin stopLoading];
}

//
- (void)URLProtocol:(NSURLProtocol *)protocol wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	[self.client URLProtocol:protocol wasRedirectedToRequest:request redirectResponse:redirectResponse];
}
- (void)URLProtocol:(NSURLProtocol *)protocol cachedResponseIsValid:(NSCachedURLResponse *)cachedResponse
{
	[self.client URLProtocol:protocol cachedResponseIsValid:cachedResponse];
}
- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveResponse:(NSURLResponse *)response cacheStoragePolicy:(NSURLCacheStoragePolicy)policy
{
	//
	//
	NSLog(@"Enter %s", __PRETTY_FUNCTION__);
	
	
	[self.client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:policy];
}
- (void)URLProtocol:(NSURLProtocol *)protocol didLoadData:(NSData *)data
{
	//
	//
	NSLog(@"Enter %s", __PRETTY_FUNCTION__);
	
	
	[self.client URLProtocol:protocol didLoadData:data];
}
- (void)URLProtocolDidFinishLoading:(NSURLProtocol *)protocol
{
	[self.client URLProtocolDidFinishLoading:protocol];
}
- (void)URLProtocol:(NSURLProtocol *)protocol didFailWithError:(NSError *)error
{
	[self.client URLProtocol:protocol didFailWithError:error];
}
- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[self.client URLProtocol:protocol didReceiveAuthenticationChallenge:challenge];
}
- (void)URLProtocol:(NSURLProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[self.client URLProtocol:protocol didCancelAuthenticationChallenge:challenge];
}


@end
