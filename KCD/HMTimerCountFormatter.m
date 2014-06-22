//
//  HMTimerCountFormatter.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMTimerCountFormatter.h"

@implementation HMTimerCountFormatter
- (NSString *)stringForObjectValue:(id)obj
{
	NSInteger timeInterval = 0;
	if([obj isKindOfClass:[NSValue class]]) {
		timeInterval = [obj doubleValue];
	} else if([obj isKindOfClass:[NSDate class]]) {
		timeInterval = [obj timeIntervalSince1970];
	} else {
		NSLog(@"obj class is %@", NSStringFromClass([obj class]));
		return @"";
	}
	
	timeInterval += [[NSTimeZone systemTimeZone] secondsFromGMT];
	
	NSInteger hour = timeInterval / (60 * 60);
	timeInterval -= hour * 60 * 60;
	NSInteger minutes = timeInterval / 60;
	timeInterval -= minutes * 60;
	NSInteger seconds = timeInterval;
	
	return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, minutes, seconds];
}
@end
