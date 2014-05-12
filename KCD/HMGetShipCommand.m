//
//  HMGetShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMGetShipCommand.h"

#import "HMMemberKDockCommand.h"
#import "HMKenzoMarkCommand.h"

@implementation HMGetShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_kousyou/getship"];
}

- (id)init
{
	self = [super initWithCommands:
			[HMMemberKDockCommand new], [HMKenzoMarkCommand new],
			nil];
	return self;
}
@end
