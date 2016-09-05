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

@property NSInteger notifyTimeBeforeTimeSignal;
@property NSTimer *timer;

@property (weak) NSUserDefaultsController *udController;
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
        _udController = [NSUserDefaultsController sharedUserDefaultsController];
        [_udController addObserver:self
                        forKeyPath:@"values.notifyTimeBeforeTimeSignal"
                           options:0
                           context:NULL];
    }
    
    return self;
}
- (void)dealloc
{
    [_udController removeObserver:self forKeyPath:@"values.notifyTimeBeforeTimeSignal"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"values.notifyTimeBeforeTimeSignal"]) {
        self.notifyTimeBeforeTimeSignal = HMStandardDefaults.notifyTimeBeforeTimeSignal.integerValue;
        [self registerTimer];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)fire:(NSTimer *)timer
{
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSInteger minutes = [cal component:NSCalendarUnitMinute fromDate:now];
    
    if(HMStandardDefaults.notifyTimeSignal) {
        if((59 - minutes) <= self.notifyTimeBeforeTimeSignal) {
            // Notify
            NSUserNotification * notification = [NSUserNotification new];
            NSString *format = NSLocalizedString(@"It is soon %zd o'clock.", @"It is soon %zd o'clock.");
            NSInteger hour = [cal component:NSCalendarUnitHour fromDate:now];
            notification.title = [NSString stringWithFormat:format, hour + 1];
            notification.informativeText = notification.title;
            if(HMStandardDefaults.playNotifyTimeSignalSound) {
                notification.soundName = NSUserNotificationDefaultSoundName;
            }
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    
    [self registerTimer];
}

- (void)registerTimer
{
    [self.timer invalidate];
    
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour
                                    fromDate:now];
    NSInteger minutes = [cal component:NSCalendarUnitMinute fromDate:now];
    
    if((59 - minutes) <= self.notifyTimeBeforeTimeSignal) {
        comp.hour = comp.hour + 1;
    }
    comp.minute = 60 - self.notifyTimeBeforeTimeSignal;
    
    NSDate *notifyDate = [cal dateFromComponents:comp];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[notifyDate timeIntervalSinceNow]
                                                  target:self
                                                selector:@selector(fire:)
                                                userInfo:nil
                                                 repeats:NO];
}
@end
