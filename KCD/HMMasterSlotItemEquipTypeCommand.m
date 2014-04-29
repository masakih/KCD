//
//  HMMasterSlotItemEquipTypeCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/30.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterSlotItemEquipTypeCommand.h"

@implementation HMMasterSlotItemEquipTypeCommand
- (NSString *)dataKey
{
	return @"api_data.api_mst_slotitem_equiptype";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterSlotItemEquipType"];
}
@end
