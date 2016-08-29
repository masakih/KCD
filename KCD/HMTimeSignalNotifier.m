//
//  HMTimeSignalNotifier.m
//  KCD
//
//  Created by Hori,Masaki on 2016/08/27.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMTimeSignalNotifier.h"

#import "HMUserDefaults.h"


static HMTimeSignalNotifier *sInstance = nil;

@interface HMTimeSignalNotifier ()
@property NSTimer *timer;
@end

@implementation HMTimeSignalNotifier

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[self class] new];
    });
}

- (instancetype)init
{
    self = [super init];
    if(self) {
        [self registerTimer];
    }
    
    return self;
}

- (void)fire:(NSTimer *)timer
{
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSInteger minutes = [cal component:NSCalendarUnitMinute fromDate:now];
    
    if((59 - minutes) <= self.notifyTimeBeforeTimeSignal) {
        // Notify
        NSUserNotification * notification = [NSUserNotification new];
        NSString *format = NSLocalizedString(@"It is soon %zd o'clock.", @"It is soon %zd o'clock.");
        NSInteger hour = [cal component:NSCalendarUnitHour fromDate:now];
        notification.title = [NSString stringWithFormat:format, hour + 1];
        notification.informativeText = notification.title;
        if(HMStandardDefaults.playFinishMissionSound) {
            notification.soundName = NSUserNotificationDefaultSoundName;
        }
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    
    [self registerTimer];
}

- (NSInteger)notifyTimeBeforeTimeSignal
{
    return 5;
}

- (void)registerTimer
{
    [self.timer invalidate];
    
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour
                                    fromDate:now];
    if(self.timer) {
        comp.hour = comp.hour + 1;
    }
    comp.minute = 60 - self.notifyTimeBeforeTimeSignal;
    
    NSDate *notifyDate = [cal dateFromComponents:comp];
    NSLog(@"notify date -> %@", notifyDate);
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[notifyDate timeIntervalSinceNow]
                                                  target:self
                                                selector:@selector(fire:)
                                                userInfo:nil
                                                 repeats:NO];
}
@end
