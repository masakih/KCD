//
//  HMCreateSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCreateSlotItemCommand.h"

#import "HMMemberMaterialCommand.h"
#import "HMUpdateSlotItemCommand.h"
#import "HMStoreCreateSlotItemHistoryCommand.h"


@implementation HMCreateSlotItemCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kousyou/createitem"]) return YES;
	
	return NO;
}
- (id)init
{
	self = [super init];
	self = [[super class] compositCommandWithCommands:
			[HMMemberMaterialCommand new],
			[HMUpdateSlotItemCommand new],
			[HMStoreCreateSlotItemHistoryCommand new],
			nil];
	return self;
}

@end
