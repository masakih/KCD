//
//  HMAPIResponse.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/21.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMAPIResponse.h"

#import "HMAppDelegate.h"


@interface HMAPIResponse ()
@property (copy, readwrite) NSString *api;
@property (nonatomic, copy, readwrite) NSDictionary *parameter;
@property (nonatomic, strong, readwrite) id json;
@property (strong, readwrite) NSDate *date;
@property (nonatomic, readwrite) BOOL success;
@property (copy, readwrite) NSString *errorString;

@property (nonatomic, copy) NSData *jsonData;
@property (nonatomic, copy) NSString *paramString;

@end

@implementation HMAPIResponse

+ (instancetype)apiResponseWithRequest:(NSURLRequest *)request data:(NSData *)data
{
	return [[self alloc] initWithRequest:request data:data];
}
- (instancetype)initWithRequest:(NSURLRequest *)request data:(NSData *)data
{
	self = [super init];
	if(self) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if(![string hasPrefix:@"svdata="]) {
			HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
			[appDelegate logLineReturn:@"recive data has not prefix svdata=. api -> %@.", request.URL.path];
			[appDelegate logLineReturn:@"Original strings -> %@", string];
			return nil;
		}
		string = [string substringFromIndex:strlen("svdata=")];
		_jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
		
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
	self.json = json;
    self.success = YES;
    if(![[json objectForKey:@"api_result"] isEqual:@1]) {
        self.success = NO;
    }
}

- (id)json
{
	if(_json) return _json;
	
	[self parseJSON];
	return _json;
}

- (void)parseParameter
{
    NSString *unescape = self.paramString.stringByRemovingPercentEncoding;
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
#if ENABLE_JSON_LOG
- (NSArray *)argumentArray
{
	if(_argumentArray) return _argumentArray;
	
	[self parseParameter];
	return _argumentArray;
}
#endif

- (BOOL)success
{
	if(_json) return _success;
	
	[self parseJSON];
	return _success;
}
@end
