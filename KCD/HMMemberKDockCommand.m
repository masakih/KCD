//
//  HMMemberKDockCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberKDockCommand.h"

@implementation HMMemberKDockCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/kdock"];
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"KenzoDock"];
}
@end
