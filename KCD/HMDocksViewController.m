//
//  HMDocksViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDocksViewController.h"

#import "HMCoreDataManager.h"

#import "HMMissionStatus.h"
#import "HMNyukyoDockStatus.h"


@interface HMDocksViewController ()


// NSUserNotifyを行ったか
@property BOOL nDock1Notified;
@property BOOL nDock2Notified;
@property BOOL nDock3Notified;
@property BOOL nDock4Notified;

@property BOOL kDock1Notified;
@property BOOL kDock2Notified;
@property BOOL kDock3Notified;
@property BOOL kDock4Notified;



@property (strong) HMMissionStatus *mission2Status;
@property (strong) HMMissionStatus *mission3Status;
@property (strong) HMMissionStatus *mission4Status;

@property (strong) HMNyukyoDockStatus *ndock1Status;
@property (strong) HMNyukyoDockStatus *ndock2Status;
@property (strong) HMNyukyoDockStatus *ndock3Status;
@property (strong) HMNyukyoDockStatus *ndock4Status;


@end

@implementation HMDocksViewController


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		_mission2Status = [[HMMissionStatus alloc] initWithDeckNumber:2];
		_mission2Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"deck2Time" toObject:self.mission2Status withKeyPath:@"time" options:nil];
		[self bind:@"mission2Name" toObject:self.mission2Status withKeyPath:@"name" options:nil];
		
		_mission3Status = [[HMMissionStatus alloc] initWithDeckNumber:3];
		_mission3Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"deck3Time" toObject:self.mission3Status withKeyPath:@"time" options:nil];
		[self bind:@"mission3Name" toObject:self.mission3Status withKeyPath:@"name" options:nil];
		
		_mission4Status = [[HMMissionStatus alloc] initWithDeckNumber:4];
		_mission4Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"deck4Time" toObject:self.mission4Status withKeyPath:@"time" options:nil];
		[self bind:@"mission4Name" toObject:self.mission4Status withKeyPath:@"name" options:nil];
		
		
		//
		_ndock1Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:1];
		_ndock1Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock1Time" toObject:self.ndock1Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock1ShipName" toObject:self.ndock1Status withKeyPath:@"name" options:nil];
		
		_ndock2Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:2];
		_ndock2Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock2Time" toObject:self.ndock2Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock2ShipName" toObject:self.ndock2Status withKeyPath:@"name" options:nil];
		
		_ndock3Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:3];
		_ndock3Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock3Time" toObject:self.ndock3Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock3ShipName" toObject:self.ndock3Status withKeyPath:@"name" options:nil];
		
		_ndock4Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:4];
		_ndock4Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock4Time" toObject:self.ndock4Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock4ShipName" toObject:self.ndock4Status withKeyPath:@"name" options:nil];
	}
	return self;
}

- (void)awakeFromNib
{
	[NSTimer scheduledTimerWithTimeInterval:0.33
									 target:self
								   selector:@selector(fire:)
								   userInfo:nil
									repeats:YES];
}

#pragma mark - Docking

- (NSNumber *)nDockTimeForNDock:(NSObjectController *)nDock
{
	NSNumber *state =[nDock valueForKeyPath:@"selection.state"];
	if(![state isKindOfClass:[NSNumber class]]) return nil;
	if([state isEqualToNumber:@0]) return nil;
	if([state isEqualToNumber:@(-1)]) return nil;
	
	NSNumber *compTimeValue = [nDock valueForKeyPath:@"selection.complete_time"];
	if(![compTimeValue isKindOfClass:[NSNumber class]]) return nil;
	
	NSTimeInterval compTime = (NSUInteger)([compTimeValue doubleValue] / 1000.0);
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	
	if(diff < 0) {
		return @( - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	} else {
		return @(diff - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	}
}
- (void)notifyIfNeededFinishBuildAtDockNumber:(NSUInteger)number
{
	static NSArray *timeKeys = nil;
	if(!timeKeys) {
		timeKeys = @[@"kDock1Time", @"kDock2Time", @"kDock3Time", @"kDock4Time"];
	}
	static NSArray *notifiedKeys = nil;
	if(!notifiedKeys) {
		notifiedKeys = @[@"kDock1Notified", @"kDock2Notified", @"kDock3Notified", @"kDock4Notified"];
	}
	
	NSTimeInterval time = [[self valueForKey:timeKeys[number - 1]] doubleValue];
	
	if(time <= - [[NSTimeZone systemTimeZone] secondsFromGMT]) {
		BOOL flag = [[self valueForKey:notifiedKeys[number -1]] boolValue];
		if(!flag) {
			NSUserNotification * notification = [NSUserNotification new];
			NSString *format = NSLocalizedString(@"It Will Finish Build at No.%ld.", @"It Will Finish Build at No.%ld.");
			notification.title = [NSString stringWithFormat:format, number];
			notification.informativeText = [NSString stringWithFormat:format, number];
			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
			[self setValue:@YES forKey:notifiedKeys[number - 1]];
		}
	} else {
		[self setValue:@NO forKey:notifiedKeys[number - 1]];
	}
}

- (void)fire:(id)timer
{
	// 入渠ドック
	[self.ndock1Status update];
	[self.ndock2Status update];
	[self.ndock3Status update];
	[self.ndock4Status update];
	
	// 建造ドック
	self.kDock1Time = [self nDockTimeForNDock:self.kDock1];
	self.kDock2Time = [self nDockTimeForNDock:self.kDock2];
	self.kDock3Time = [self nDockTimeForNDock:self.kDock3];
	self.kDock4Time = [self nDockTimeForNDock:self.kDock4];
	
	[self notifyIfNeededFinishBuildAtDockNumber:1];
	[self notifyIfNeededFinishBuildAtDockNumber:2];
	[self notifyIfNeededFinishBuildAtDockNumber:3];
	[self notifyIfNeededFinishBuildAtDockNumber:4];
	
	// 遠征
	[self.mission2Status update];
	[self.mission3Status update];
	[self.mission4Status update];
}

@end
