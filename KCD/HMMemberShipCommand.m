//
//  HMMemberShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberShipCommand.h"

@implementation HMMemberShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/ship"];
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"Ship"];
}
@end
