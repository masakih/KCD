//
//  HMKCQuest+Extensions.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/08.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMKCQuest+Extensions.h"

@implementation HMKCQuest (Extension)

+ (NSSet *)keyPathsForValuesAffectingCompositStatus
{
	return [NSSet setWithObjects:@"state", @"progress_flag", nil];
}
- (NSNumber *)compositStatus
{
	NSNumber *stat = self.state;
	NSNumber *progress = self.progress_flag;
	
	return @(progress.integerValue * 4 + stat.integerValue);
}

@end
