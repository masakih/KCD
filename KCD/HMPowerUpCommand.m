//
//  HMPowerUpCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPowerUpCommand.h"

#import "HMMemberShipCommand.h"
#import "HMMemberDeckCommand.h"
#import "HMRealPowerUpCommand.h"

@implementation HMPowerUpCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kaisou/powerup"]) return YES;
	return NO;
}
- (id)init
{
	self = [super initWithCommands:
			[HMMemberShipCommand new],
			[HMMemberDeckCommand new],
			[HMRealPowerUpCommand new],
			nil];
	return self;
}

@end
