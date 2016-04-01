//
//  HMMemberRequireInfoCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/04/01.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMMemberRequireInfoCommand.h"

#import "HMMemberSlotItemCommand.h"
#import "HMMemberKDockCommand.h"


@implementation HMMemberRequireInfoCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/require_info"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberSlotItemCommand new],
			[HMMemberKDockCommand new],
			nil];
	return self;
}
@end
