//
//  HMShipDeckCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/18.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMShipDeckCommand.h"

#import "HMMemberShipCommand.h"
#import "HMMemberDeckCommand.h"
#import "HMDummyShipCommand.h"
#import "HMGuardShelterCommand.h"

@implementation HMShipDeckCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/ship_deck"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberShipCommand new],
			[HMMemberDeckCommand new],
			[HMDummyShipCommand new],
			[HMGuardShelterCommand new],
			nil];
	return self;
}
@end
