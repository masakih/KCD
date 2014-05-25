//
//  HMBattleCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBattleCommand.h"

#import "HMCalculateDamageCommand.h"

@implementation HMBattleCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_sortie/battle"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMCalculateDamageCommand new],
			nil];
	return self;
}
@end
