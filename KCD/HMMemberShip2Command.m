//
//  HMMemberShip2Command.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/15.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberShip2Command.h"

#import "HMMemberShipCommand.h"
#import "HMMemberDeckCommand.h"
#import "HMDropShipHistoryCommand.h"

@implementation HMMemberShip2Command
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/ship2"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberShipCommand new], [HMMemberDeckCommand new],
			[HMDropShipHistoryCommand new],
			nil];
	return self;
}
@end
