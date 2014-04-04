//
//  HMCompositMapCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/04.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCompositMapCommand.h"

#import "HMMasterMapAreaCommand.h"
#import "HMMasterMapInfoCommand.h"
#import "HMMasterMapCellCommand.h"


@implementation HMCompositMapCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_start"];
}

- (id)init
{
	self = [super init];
	self = [[super class] compositCommandWithCommands:[HMMasterMapAreaCommand new], [HMMasterMapInfoCommand new], [HMMasterMapCellCommand new], nil];
	return self;
}
@end
