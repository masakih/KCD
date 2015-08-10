//
//  HMResourceHistoryManager.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/04.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMResourceHistoryManager.h"

#import "HMServerDataStore.h"
#import "HMResourceHistoryDataStore.h"

#import "HMKCMaterial.h"
#import "HMKCBasic.h"
#import "HMKCResource.h"

static HMResourceHistoryManager *sInstance;


@interface HMResourceHistoryManager ()
@property (strong) NSTimer *timer;

@end
@implementation HMResourceHistoryManager
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		sInstance = [self new];
		[sInstance run];
	});
}

- (void)run
{
	[self notifyIfNeeded:nil];
	
}

- (void)notifyIfNeeded:(id)timer
{
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSCalendarUnit unit = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
	NSDateComponents *currentHour = [[NSCalendar currentCalendar] components:unit fromDate:now];
	
	if(self.timer) {
		[self saveResources];
	}
	
	if(self.timer.valid) {
		[self.timer invalidate];
	}
	
	currentHour.minute += 5;
	NSInteger minute = (currentHour.minute + 2) / 5;
	minute *= 5;
	currentHour.minute = minute;
	NSDate *nextNotifyDate = [[NSCalendar currentCalendar] dateFromComponents:currentHour];
	NSTimeInterval nextNotifyTime = [nextNotifyDate timeIntervalSinceNow];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:nextNotifyTime
												  target:self
												selector:_cmd
												userInfo:nil
												 repeats:NO];
}

- (void)saveResources
{
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	
	NSError *error = nil;
	NSArray *materials = [store objectsWithEntityName:@"Material"
											predicate:nil
												error:&error];
	if(error) {
		NSLog(@"Fetch error -> %@", error);
		return;
	}
	if([materials count] == 0) {
		NSLog(@"Material data is invalid.");
		return;
	}
	HMKCMaterial *material = materials[0];
	
	
	NSArray *basics = [store objectsWithEntityName:@"Basic"
											predicate:nil
												error:&error];
	if(error) {
		NSLog(@"Fetch error -> %@", error);
		return;
	}
	if([basics count] == 0) {
		NSLog(@"Basic data is invalid.");
		return;
	}
	HMKCBasic *basic = basics[0];
	
	HMResourceHistoryDataStore *resourceStore = [HMResourceHistoryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = resourceStore.managedObjectContext;
	
	HMKCResource *newResource = [NSEntityDescription insertNewObjectForEntityForName:@"Resource"
															  inManagedObjectContext:moc];
	
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSCalendarUnit unit = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
	NSDateComponents *currentHour = [[NSCalendar currentCalendar] components:unit fromDate:now];
	
	NSInteger minute = (currentHour.minute + 2) / 5;
	minute *= 5;
	currentHour.minute = minute;
	
	newResource.date = [[NSCalendar currentCalendar] dateFromComponents:currentHour];
	newResource.minute = @(minute != 60 ? minute : 0);
	newResource.bauxite = material.bauxite;
	newResource.bull = material.bull;
	newResource.fuel = material.fuel;
	newResource.kaihatusizai = material.kaihatusizai;
	newResource.kousokukenzo = material.kousokukenzo;
	newResource.kousokushuhuku = material.kousokushuhuku;
	newResource.screw = material.screw;
	newResource.steel = material.steel;
	newResource.experience = basic.experience;
	
	[resourceStore saveAction:nil];
	
}

@end
