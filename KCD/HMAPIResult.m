//
//  HMAPIResult.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/21.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMAPIResult.h"

#import "HMAppDelegate.h"


@interface HMAPIResult ()
@property (strong, readwrite, nonatomic) NSString *api;
@property (strong, readwrite, nonatomic) NSDictionary *parameter;
@property (strong, readwrite, nonatomic) id json;
@property (strong, readwrite, nonatomic) NSDate *date;
@property (readwrite, nonatomic) BOOL success;
@property (strong, readwrite, nonatomic) NSString *errorString;

@property (strong, nonatomic) NSData *jsonData;
@property (strong, nonatomic) NSString *paramString;

@end

@implementation HMAPIResult

- (instancetype)initWithRequest:(NSURLRequest *)request data:(NSData *)data
{
	self = [super init];
	if(self) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSArray *elements = [string componentsSeparatedByString:@"="];
		if([elements count] != 2) {
			HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
			[appDelegate logLineReturn:@"we could not compose data. api -> %@. Number of elements: %ld", request.URL.path, [elements count]];
			[appDelegate logLineReturn:@"Original strings -> %@", string];
			return nil;
		}
		_jsonData = [elements[1] dataUsingEncoding:NSUTF8StringEncoding];
		
		NSData *requestBodyData = [request HTTPBody];
		_paramString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
		
		_api = request.URL.path;
		_date = [NSDate dateWithTimeIntervalSinceNow:0];
	}
	
	return self;
}

- (void)parseJSON
{
	NSError *error = nil;
	id json = [NSJSONSerialization JSONObjectWithData:self.jsonData
											  options:NSJSONReadingAllowFragments
												error:&error];
	if(error) {
		HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
		[appDelegate logLineReturn:@"Fail decode JSON data %@", error];
		return;
	}
	if(![json isKindOfClass:[NSDictionary class]]) {
		self.errorString = @"JSON is NOT NSDictionary.";
		return;
	}
	if(![[json objectForKey:@"api_result"] isEqual:@1]) {
		self.success = NO;
		return;
	}
	self.success = YES;
	self.json = json;
}

- (id)json
{
	if(_json) return _json;
	
	[self parseJSON];
	return _json;
}

- (void)parseParameter
{
	NSString *unescape = [self.paramString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSArray *pair = [unescape componentsSeparatedByString:@"&"];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	for(NSString *p in pair) {
		NSArray *pp = [p componentsSeparatedByString:@"="];
		if([pp count] != 2) {
			NSLog(@"API (%@): Bad Argument: pair is odd.", self.api);
			continue;
		}
		[dict setObject:pp[1] forKey:pp[0]];
	}
	_parameter = dict;
	
#if ENABLE_JSON_LOG
	NSMutableArray *array = [NSMutableArray new];
	for(NSString *p in pair) {
		NSArray *pp = [p componentsSeparatedByString:@"="];
		if([pp count] != 2) {
			NSLog(@"API (%@): Bad Argument: pair is odd.", self.api);
			continue;
		}
		[array addObject:@{@"key": pp[0], @"value": pp[1]}];
	}
	self.argumentArray = array;
#endif
	
}
- (NSDictionary *)parameter
{
	if(_parameter) return _parameter;
	
	[self parseParameter];
	return _parameter;
}
- (NSArray *)argumentArray
{
	if(_argumentArray) return _argumentArray;
	
	[self parseParameter];
	return _argumentArray;
}

- (BOOL)success
{
	if(_json) return _success;
	
	[self parseJSON];
	return _success;
}
@end
