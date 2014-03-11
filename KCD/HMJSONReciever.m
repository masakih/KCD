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
	while(![path isEqualToString:@"/"]) {
		if([path hasSuffix:@"kcsapi"]) {
			[self setProtocol:protocol];
		}
		path = [path stringByDeletingLastPathComponent];
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
	if(!data) return;
	
#define JSON_LOG_STRING 0
#if JSON_LOG_STRING
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[self logLineReturn:@"body -> \n%@", string];
#else
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSArray *elements = [string componentsSeparatedByString:@"="];
	if([elements count] != 2) {
		[[NSApp delegate] logLineReturn:@"\e[1mwe could not compose data. api -> %@. Number of elements:\e[22m %ld", protocol.request.URL.path, [elements count]];
		[[NSApp delegate] logLineReturn:@"Original strings -> %@", string];
		[self removeDataForProtocol:protocol];
		return;
	}
	NSData *JSONData = [elements[1] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSData *requestBodyData = [protocol.request HTTPBody];
	NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
	
	[self.queueu enqueue:@{@"api" : protocol.request.URL.path, @"argument": requestBodyString, @"json" : JSONData}];
	
#endif
	
	
	[self removeDataForProtocol:protocol];
}
- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didFailWithError:(NSError *)error
{
	[self removeDataForProtocol:protocol];
}


//- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)argList
//{
//	[self logLineReturn:[[NSString alloc] initWithFormat:format arguments:argList]];
//}


@end
