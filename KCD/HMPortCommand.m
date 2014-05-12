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
			nil];
	return self;
}
@end
