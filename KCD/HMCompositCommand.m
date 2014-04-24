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
	HMCompositCommand *result = [HMCompositCommand new];
	
	result.commands = [NSMutableArray new];
	
	va_list ap;
	va_start(ap, cmd1);
	HMJSONCommand *command = cmd1;
	while(command) {
		[result.commands addObject:command];
		command = va_arg(ap, id);
	}
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
- (void)setArgumentsString:(NSString *)argumentsString
{
	for(id command in self.commands) {
		[command setArgumentsString:argumentsString];
	}
}
- (void)setJsonData:(NSData *)jsonData
{
	for(id command in self.commands) {
		[command setJsonData:jsonData];
	}
}
- (void)setRecieveDate:(NSDate *)recieveDate
{
	for(id command in self.commands) {
		[command setRecieveDate:recieveDate];
	}
}


@end
