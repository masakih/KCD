//
//  HMMasterSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterSlotItemCommand.h"

@implementation HMMasterSlotItemCommand
//+ (void)load
//{
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		[HMJSONCommand registerClass:self];
//	});
//}
//
//+ (BOOL)canExcuteAPI:(NSString *)api
//{
//	return [api isEqualToString:@"/kcsapi/api_get_master/slotitem"];
//}
- (NSString *)dataKey
{
	return @"api_data.api_mst_slotitem";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterSlotItem"];
}
@end
