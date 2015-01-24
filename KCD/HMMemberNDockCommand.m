//
//  HMMemberNDockCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/18.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberNDockCommand.h"

@implementation HMMemberNDockCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/ndock"];
}

- (NSString *)dataKey
{
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]) {
		return @"api_data.api_ndock";
	}
	return [super dataKey];
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"NyukyoDock"];
}
@end
