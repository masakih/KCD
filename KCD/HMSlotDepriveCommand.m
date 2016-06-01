//
//  HMSlotDepriveCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/06/01.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMSlotDepriveCommand.h"

#import "HMMemberShipCommand.h"
#import "HMSlotDepriveUnsetCommand.h"

@implementation HMSlotDepriveCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_kaisou/slot_deprive"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberShipCommand new],
			[HMSlotDepriveUnsetCommand new],
			nil];
	return self;
}
@end
