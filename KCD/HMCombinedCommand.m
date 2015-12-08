//
//  HMCombinedCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/11/26.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMCombinedCommand.h"


NSString *HMCombinedCommandCombinedDidCangeNotification = @"HMCombinedCommandCombinedDidCangeNotification";
NSString		*HMCombinedType = @"HMCombinedType";

@implementation HMCombinedCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}
+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_hensei/combined"]) return YES;
	return NO;
}
- (void)execute
{
	id type = nil;
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]) {
		NSDictionary *data = self.json[@"api_data"];
		type = data[@"api_combined_flag"];
		if(!type) {
			type = @(cancel);
		}
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_hensei/combined"]) {
		type = self.arguments[@"api_combined_type"];
	}
	if(!type) return;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:HMCombinedCommandCombinedDidCangeNotification
					  object:self
					userInfo:@{
							   HMCombinedType : type
							   }];
}
@end
