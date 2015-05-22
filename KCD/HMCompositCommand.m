//
//  HMCompositCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/14.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCompositCommand.h"

@interface HMCompositCommand ()
@property (strong) NSMutableArray *commands;
@end

@implementation HMCompositCommand

+ (id)compositCommandWithCommands:(HMJSONCommand *)cmd1, ...
{
	id result = nil;
	va_list ap;
	va_start(ap, cmd1);
	result = [[self alloc] initWithCommand:cmd1 list:ap];
	va_end(ap);
	
	return result;
}

- (id)initWithCommand:(HMJSONCommand *)cmd1 list:(va_list)argList
{
	self = [super init];
	if(self) {
		_commands = [NSMutableArray new];
		HMJSONCommand *command = cmd1;
		while(command) {
			[_commands addObject:command];
			command = va_arg(argList, id);
		}
	}
	
	return self;
}

- (id)initWithCommands:(HMJSONCommand *)cmd1, ...
{
	va_list ap;
	va_start(ap, cmd1);
	HMCompositCommand *result = [self initWithCommand:cmd1 list:ap];
	va_end(ap);
	
	return result;
}

- (void)execute
{
	for(HMJSONCommand *command in self.commands) {
		[command execute];
	}
}

- (void)setApi:(NSString *)api
{
	for(id command in self.commands) {
		[command setApi:api];
	}
}
- (void)setRecieveDate:(NSDate *)recieveDate
{
	for(id command in self.commands) {
		[command setRecieveDate:recieveDate];
	}
}

- (void)setJson:(id)json
{
	for(id command in self.commands) {
		[command setJson:json];
	}
}
- (void)setArguments:(NSDictionary *)arguments
{
	for(id command in self.commands) {
		[command setArguments:arguments];
	}
}


@end
