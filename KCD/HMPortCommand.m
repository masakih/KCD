//
//  HMPortCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPortCommand.h"

#import "HMMemberShipCommand.h"
#import "HMMemberMaterialCommand.h"
#import "HMMemberDeckCommand.h"
#import "HMMemberBasicCommand.h"
#import "HMMemberNDockCommand.h"
#import "HMResetSortieCommand.h"
#import "HMDropShipHistoryCommand.h"
#import "HMDummyShipCommand.h"
#import "HMPortNotifyCommand.h"


@implementation HMPortCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_port/port"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberShipCommand new], [HMMemberMaterialCommand new],
			[HMMemberDeckCommand new], [HMMemberBasicCommand new],
			[HMMemberNDockCommand new],
			[HMResetSortieCommand new],
			[HMDropShipHistoryCommand new],
			[HMDummyShipCommand new],
			[HMPortNotifyCommand new],
			nil];
	return self;
}
@end
