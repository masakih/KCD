//
//  HMCompositMapCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/04.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMStart2Command.h"

#import "HMMasterMapAreaCommand.h"
#import "HMMasterMapInfoCommand.h"
#import "HMMasterMapCellCommand.h"
#import "HMMasterSTypeCommand.h"
#import "HMMaserShipCommand.h"
#import "HMMasterMissionCommand.h"
#import "HMMasterFurnitureCommand.h"
#import "HMMasterSlotItemCommand.h"
#import "HMMasterUseItemCommand.h"
#import "HMMasterSlotItemEquipTypeCommand.h"


@implementation HMStart2Command
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_start2"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMasterMapAreaCommand new], [HMMasterMapInfoCommand new], [HMMasterMapCellCommand new],
			[HMMasterSTypeCommand new], [HMMaserShipCommand new],
			[HMMasterMissionCommand new],
			[HMMasterFurnitureCommand new],
			[HMMasterSlotItemEquipTypeCommand new],
			[HMMasterSlotItemCommand new], [HMMasterUseItemCommand new],
			nil];
	return self;
}
@end
