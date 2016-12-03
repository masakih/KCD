//
//  HMBattleResultCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/25.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBattleResultCommand.h"

#import "HMCalculateDamageCommand.h"
#import "HMDropShipHistoryCommand.h"
#import "HMDummyShipCommand.h"
#import "HMGuardShelterCommand.h"


@implementation HMBattleResultCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
    if([api isEqualToString:@"/kcsapi/api_req_sortie/battleresult"]) return YES;
    if([api isEqualToString:@"/kcsapi/api_req_combined_battle/battleresult"]) return YES;
    
    return NO;
}

- (id)init
{
	self = [super initWithCommands:
			[HMDropShipHistoryCommand new],
			[HMCalculateDamageCommand new],
			[HMDummyShipCommand new],
            [HMGuardShelterCommand new],
			nil];
	return self;
}
@end
