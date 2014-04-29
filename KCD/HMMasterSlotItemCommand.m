//
//  HMMasterSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterSlotItemCommand.h"

@implementation HMMasterSlotItemCommand
- (NSString *)dataKey
{
	return @"api_data.api_mst_slotitem";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterSlotItem"];
}
@end
