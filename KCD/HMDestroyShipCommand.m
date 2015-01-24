//
//  HMDestroyShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/07/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDestroyShipCommand.h"

#import "HMRealDestroyShipCommand.h"
#import "HMMemberMaterialCommand.h"


@implementation HMDestroyShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kousyou/destroyship"]) return YES;
	
	return NO;
}
- (id)init
{
	self = [super initWithCommands:
 			[HMMemberMaterialCommand new],
			[HMRealDestroyShipCommand new],
			nil];
	return self;
}
@end
