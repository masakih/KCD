//
//  HMHokyuChargeCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMHokyuChargeCommand.h"

#import "HMMemberMaterialCommand.h"
#import "HMApplySuppliesCommand.h"


@implementation HMHokyuChargeCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_hokyu/charge"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberMaterialCommand new],
			[HMApplySuppliesCommand new],
			nil];
	return self;
}
@end
