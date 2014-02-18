//
//  HMMasterFurnitureCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/17.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterFurnitureCommand.h"

@implementation HMMasterFurnitureCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_master/furniture"];
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterFurniture"];
}
@end
