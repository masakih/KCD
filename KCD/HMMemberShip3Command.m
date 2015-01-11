//
//  HMMemberShip3Command.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/15.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberShip3Command.h"

#import "HMMemberShipCommand.h"

#import "KCD-Swift.h"

@implementation HMMemberShip3Command
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/ship3"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberShipCommand new],
			[HMMemberDeckCommand new],
			nil];
	return self;
}
@end
