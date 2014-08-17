//
//  HMCombinedBattleCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/08/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCombinedBattleCommand.h"

#import "HMCalculateDamageCommand.h"

@implementation HMCombinedBattleCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_combined_battle/battle"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_req_combined_battle/airbattle"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_req_combined_battle/midnight_battle"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_req_combined_battle/battleresult"]) return YES;
	
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
