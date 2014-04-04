//
//  HMMasterMapAreaCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterMapAreaCommand.h"

@implementation HMMasterMapAreaCommand
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
//	return [api isEqualToString:@"/kcsapi/api_get_master/maparea"];
//}
- (NSString *)dataKey
{
	return @"api_data_mst_maparea";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterMapArea"];
}
@end
