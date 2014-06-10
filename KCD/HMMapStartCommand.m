//
//  HMMapStartCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMapStartCommand.h"

#import "HMCalculateDamageCommand.h"

@implementation HMMapStartCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_map/start"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMCalculateDamageCommand new],
			nil];
	return self;
}
@end