//
//  HMMasterSTypeCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/13.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterSTypeCommand.h"

//#import "HMMaserShipCommand.h"

//#import "HMAppDelegate.h"


@implementation HMMasterSTypeCommand
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
//	return [api isEqualToString:@"/kcsapi/api_get_master/stype"];
//}

- (NSArray *)ignoreKeys
{
	static NSArray *ignoreKeys = nil;
	if(ignoreKeys) return ignoreKeys;
	
	ignoreKeys = @[@"api_equip_type"];
	return ignoreKeys;
}
- (NSString *)dataKey
{
	return @"api_data.api_mst_stype";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterSType"];
		
//	NSCondition *lock = [HMMaserShipCommand condition];
//	[lock lock];
//	[lock broadcast];
//	[lock unlock];
}
@end
