//
//  HMJSONCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONCommand.h"

#import "HMAppDelegate.h"
#import "HMJSONNode.h"

static NSMutableArray *registerdCommands = nil;


@interface HMJSONCommand ()
@property (retain, readwrite) NSArray *arguments;
@property (copy, readwrite) NSString *api;
@property (retain, readwrite) id json;
@property (retain, readwrite) NSArray *jsonTree;

@end

@implementation HMJSONCommand
@synthesize argumentsString = _argumentsString;
@synthesize jsonData = _jsonData;

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		registerdCommands = [NSMutableArray new];
	});
}

+ (HMJSONCommand *)commandForAPI:(NSString *)api
{
	for(Class commandClass in registerdCommands) {
		if([commandClass canExcuteAPI:api]) {
			HMJSONCommand *command =  [commandClass new];
			command.api = api;
			
			return command;
		}
	}
	
	return nil;
}

+ (void)registerClass:(Class)commandClass
{
	if(!commandClass) return;
	if([registerdCommands containsObject:commandClass]) return;
	[registerdCommands addObject:commandClass];
}


- (void)setArgumentsString:(NSString *)argumentsString
{
	_argumentsString = [argumentsString copy];
	
	NSString *unescape = [_argumentsString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSArray *pair = [unescape componentsSeparatedByString:@"&"];
	NSMutableArray *array = [NSMutableArray new];
	for(NSString *p in pair) {
		NSArray *pp = [p componentsSeparatedByString:@"="];
		if([pp count] != 2) {
			NSLog(@"API (%@): Bat Argument: pair is odd.", self.api);
			continue;
		}
		[array addObject:@{@"key": pp[0], @"value": pp[1]}];
	}
	self.arguments = array;
}
- (NSString *)argumentsString
{
	return [_argumentsString copy];
}

- (void)setJsonData:(NSData *)jsonData
{
	NSError *error = nil;
	id json = [NSJSONSerialization JSONObjectWithData:jsonData
											  options:NSJSONReadingAllowFragments
												error:&error];
	if(error) {
		[[NSApp delegate] logLineReturn:@"\e[1m\e[31mFail decode JSON data\e[39m\e[22m %@", error];
	} else {
		self.json = json;
		self.jsonTree = @[[HMJSONNode nodeWithJSON:json]];
	}
}
- (NSData *)jsonData
{
	return _jsonData;
}

// abstruct
- (void)execute
{
	NSLog(@"Enter %s", __PRETTY_FUNCTION__);
	assert(NO);
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return NO;
}
- (void)prepaierOnMainThread {}

@end
