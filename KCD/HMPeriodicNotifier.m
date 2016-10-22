//
//  HMPeriodicNotifier.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/13.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMPeriodicNotifier.h"


NSString *HMPeriodicNotification = @"HMPeriodicNotification";

@interface HMPeriodicNotifier ()
@property NSUInteger hour;
@property NSUInteger minutes;

@property (nonatomic, strong) NSDateComponents *currentDay;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation HMPeriodicNotifier

+ (instancetype)periodicNotifierWithHour:(NSUInteger)hour minutes:(NSUInteger)minutes
{
	return [[self alloc] initWithHour:hour minutes:minutes];
}
- (instancetype)initWithHour:(NSUInteger)hour minutes:(NSUInteger)minutes
{
	self = [super init];
	if(self) {
		_hour = hour;
		_minutes = minutes;
		[self registerNotifications];
		[self notifyIfNeeded:nil];
	}
	return self;
}

- (void)registerNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(notifyIfNeeded:)
			   name:NSSystemTimeZoneDidChangeNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(notifyIfNeeded:)
			   name:NSSystemClockDidChangeNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(notifyIfNeeded:)
			   name:NSWorkspaceDidWakeNotification
			 object:nil];
}

- (void)notifyIfNeeded:(id)timer
{
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSCalendarUnit unit = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSDateComponents *currentDay = [[NSCalendar currentCalendar] components:unit fromDate:now];
	currentDay.hour = self.hour;
	currentDay.minute = self.minutes;
	NSDate *notifyDate = [[NSCalendar currentCalendar] dateFromComponents:currentDay];
	
	if([now compare:notifyDate] == NSOrderedDescending) {
		currentDay.day += 1;
		[[NSNotificationCenter defaultCenter] postNotificationName:HMPeriodicNotification
															object:self];
	}
	
	if(self.timer.valid) {
		[self.timer invalidate];
	}
	
	NSDate *nextNotifyDate = [[NSCalendar currentCalendar] dateFromComponents:currentDay];
	NSTimeInterval nextNotifyTime = [nextNotifyDate timeIntervalSinceNow];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:nextNotifyTime + 0.1
												  target:self
												selector:_cmd
												userInfo:nil
												 repeats:NO];
}

@end
