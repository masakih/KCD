//
//  HMRemodelSlotCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/25.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMRemodelSlotCommand.h"

#import "HMMemberMaterialCommand.h"
#import "HMRemodelSlotItemCommand.h"

@implementation HMRemodelSlotCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_kousyou/remodel_slot"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberMaterialCommand new],
			[HMRemodelSlotItemCommand new],
			nil];
	return self;
}
@end
