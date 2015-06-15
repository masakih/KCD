//
//  HMPeriodicNotifier.h
//  KCD
//
//  Created by Hori,Masaki on 2015/06/13.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMPeriodicNotifier : NSObject

// 24-hour clock
- (instancetype)initWithHour:(NSUInteger)hour minutes:(NSUInteger)minutes;
+ (instancetype)periodicNotifierWithHour:(NSUInteger)hour minutes:(NSUInteger)minutes;

@end


extern NSString *HMPeriodicNotification;
