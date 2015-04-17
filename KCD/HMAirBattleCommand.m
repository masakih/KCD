//
//  HMAirBattleCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/04/17.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMAirBattleCommand.h"

#import "HMCalculateDamageCommand.h"
#import "HMDropShipHistoryCommand.h"

@implementation HMAirBattleCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_sortie/airbattle"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMDropShipHistoryCommand new],
			[HMCalculateDamageCommand new],
			nil];
	return self;
}
@end
