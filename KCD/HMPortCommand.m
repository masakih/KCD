//
//  HMPortCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPortCommand.h"

#import "HMMemberShip2Command.h"
#import "HMMemberMaterial2Command.h"
#import "HMMemberDeck2Command.h"
#import "HMMemberBasicCommand.h"
#import "HMMemberNDock2Command.h"


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
	self = [super init];
	self = [[super class] compositCommandWithCommands:
			[HMMemberShip2Command new], [HMMemberMaterial2Command new],
			[HMMemberDeck2Command new], [HMMemberBasicCommand new],
			[HMMemberNDock2Command new],
			nil];
	return self;
}
@end
