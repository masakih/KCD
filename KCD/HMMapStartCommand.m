//
//  HMMapStartCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMapStartCommand.h"

#import "HMCalculateDamageCommand.h"
#import "HMGuardShelterCommand.h"

@implementation HMMapStartCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_map/start"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_req_map/next"]) return YES;
	
	return NO;
}

- (id)init
{
	self = [super initWithCommands:
			[HMCalculateDamageCommand new],
			[HMGuardShelterCommand new],
			nil];
	return self;
}
@end
