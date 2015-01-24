//
//  HMKenzoHistory.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKenzoHistory.h"


@implementation HMKenzoHistory

@dynamic bauxite;
@dynamic bull;
@dynamic date;
@dynamic fuel;
@dynamic kaihatusizai;
@dynamic name;
@dynamic steel;
@dynamic sTypeId;
@dynamic flagShipName;
@dynamic flagShipLv;
@dynamic commanderLv;

- (NSNumber *)isLarge
{
	return [self.fuel compare:@1000] == NSOrderedDescending ? @YES : @NO;
}

@end
