//
//  HMJSONReciever.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONReciever.h"

#import "CustomHTTPProtocol.h"
#import "HMAppDelegate.h"
#import "HMAPIResponse.h"


@interface HMJSONReciever ()
@property (strong) NSMutableDictionary *recievers;
@end


@implementation HMJSONReciever

- (id)init
{
	self = [super init];
	if(self) {
		_recievers = [NSMutableDictionary new];
		
		[CustomHTTPProtocol setDelegate:self];
	}
	return self;
}

- (void)setProtocol:(NSURLProtocol *)protocol
{
	[self.recievers setObject:[NSMutableData data]
					   forKey:[NSValue valueWithPointer:(__bridge const void *)(protocol)]];
}
- (NSMutableData *)dataForProtocol:(NSURLProtocol *)protocol
{
	return [self.recievers objectForKey:[NSValue valueWithPointer:(__bridge const void *)(protocol)]];
}
- (void)removeDataForProtocol:(NSURLProtocol *)protocol
{
	[self.recievers removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(protocol)]];
}

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didRecieveResponse:(NSHTTPURLResponse *)response
{
	NSURL *url = protocol.request.URL;
	NSString *path = url.path;
	NSArray *pathComponents = [path pathComponents];
	if([pathComponents containsObject:@"kcsapi"]) {
		[self setProtocol:protocol];
	}
}

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didRecieveData:(NSData *)data
{
	NSMutableData *loadedData = [self dataForProtocol:protocol];
	if(!loadedData) return;
	
	[loadedData appendData:data];
}

- (void)customHTTPProtocolDidFinishLoading:(CustomHTTPProtocol *)protocol
{
	NSData  *data = [self dataForProtocol:protocol];
	if(!data) {
		[self removeDataForProtocol:protocol];
		return;
	}
	
#define JSON_LOG_STRING 0
#if JSON_LOG_STRING
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[[NSApp delegate] logLineReturn:@"body -> \n%@", string];
#else
	HMAPIResponse *apiResult = [HMAPIResponse apiResponseWithRequest:protocol.request data:data];
	if(apiResult) {
		[self.queueu enqueue:apiResult];
	}
#endif
	
	[self removeDataForProtocol:protocol];
}
- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didFailWithError:(NSError *)error
{
	NSString *errorLog = [NSString stringWithFormat:@"Connection Error!.\nRequest: %@\nError: %@", protocol.request, error];
	NSLog(@"%@", errorLog);
	
	[self removeDataForProtocol:protocol];
}

//- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)argList
//{
//	NSURL *url = protocol.request.URL;
//	NSString *path = url.path;
//	NSArray *pathComponents = [path pathComponents];
//	if(![pathComponents containsObject:@"kcsapi"]) {
//		return;
//	}
//	NSString *log = [[NSString alloc] initWithFormat:format arguments:argList];
//	log = [NSString stringWithFormat:@"API: %@,Description: %@", path.lastPathComponent, log];
//	[[NSApp delegate] logLineReturn:@"%@", log];
//}


@end
