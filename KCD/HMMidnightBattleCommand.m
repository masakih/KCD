//
//  HMMidnightBattleCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMidnightBattleCommand.h"

#import "HMCalculateDamageCommand.h"

@implementation HMMidnightBattleCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_battle_midnight/battle"]) return YES;
    if([api isEqualToString:@"/kcsapi/api_req_battle_midnight/sp_midnight"]) return YES;
    if([api isEqualToString:@"/kcsapi/api_req_combined_battle/ec_midnight_battle"]) return YES;
	
	return NO;
}

- (id)init
{
	self = [super initWithCommands:
			[HMCalculateDamageCommand new],
			nil];
	return self;
}
@end
