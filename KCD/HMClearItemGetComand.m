//
//  HMClearItemGetComand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/04/22.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMClearItemGetComand.h"

#import "HMUpdateQuestListCommand.h"


@implementation HMClearItemGetComand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_quest/clearitemget"];
}

- (id)init
{
	self = [super initWithCommands:
//			[HMMemberMaterialCommand new],
			[HMUpdateQuestListCommand new],
			nil];
	return self;
}
@end
