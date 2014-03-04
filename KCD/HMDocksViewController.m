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


@interface HMDocksViewController ()


// 入渠中フラグ
@property BOOL nDock1Flag;
@property BOOL nDock2Flag;
@property BOOL nDock3Flag;
@property BOOL nDock4Flag;


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

@end

@implementation HMDocksViewController


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

+ (NSSet *)keyPathsForValuesAffectingMission2Name
{
	return [NSSet setWithObjects:@"mission2Status.name", nil];
}
+ (NSSet *)keyPathsForValuesAffectingMission3Name
{
	return [NSSet setWithObjects:@"mission3Status.name", nil];
}
+ (NSSet *)keyPathsForValuesAffectingMission4Name
{
	return [NSSet setWithObjects:@"mission4Status.name", nil];
}
+ (NSSet *)keyPathsForValuesAffectingDeck2Time
{
	return [NSSet setWithObjects:@"mission2Status.time", nil];
}
+ (NSSet *)keyPathsForValuesAffectingDeck3Time
{
	return [NSSet setWithObjects:@"mission3Status.time", nil];
}
+ (NSSet *)keyPathsForValuesAffectingDeck4Time
{
	return [NSSet setWithObjects:@"mission4Status.time", nil];
}

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		_mission2Status = [[HMMissionStatus alloc] initWithDeckNumber:2];
		_mission2Status.managedObjectContext = self.managedObjectContext;
		
		_mission3Status = [[HMMissionStatus alloc] initWithDeckNumber:3];
		_mission3Status.managedObjectContext = self.managedObjectContext;
		
		_mission4Status = [[HMMissionStatus alloc] initWithDeckNumber:4];
		_mission4Status.managedObjectContext = self.managedObjectContext;
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

#pragma mark - Mission
- (NSString *)mission2Name
{
	return self.mission2Status.name;
}
- (NSString *)mission3Name
{
	return self.mission3Status.name;
}
- (NSString *)mission4Name
{
	return self.mission4Status.name;
}
- (NSNumber *)deck2Time
{
	return self.mission2Status.time;
}
- (NSNumber *)deck3Time
{
	return self.mission3Status.time;
}
- (NSNumber *)deck4Time
{
	return self.mission4Status.time;
}
- (void)checkNameForKey:(NSString *)nameKey flagKey:(NSString *)flagKey timeValue:(id)timeValue
{
	BOOL flag = [[self valueForKey:flagKey] boolValue];
	if(flag && !timeValue) {
		[self setValue:@NO forKey:flagKey];
		[self willChangeValueForKey:nameKey];
		[self didChangeValueForKey:nameKey];
	} else if(!flag && timeValue) {
		[self setValue:@YES forKey:flagKey];
		[self willChangeValueForKey:nameKey];
		[self didChangeValueForKey:nameKey];
	}
}

#pragma mark - Docking
- (NSString *)shipNameForNDockNumber:(NSUInteger)number
{
	static NSArray *shipIdKeys = nil;
	if(!shipIdKeys) {
		shipIdKeys = @[@"nDock1.selection.ship_id", @"nDock2.selection.ship_id", @"nDock3.selection.ship_id", @"nDock4.selection.ship_id"];
	}
	
	NSNumber *nDockShipId = [self valueForKeyPath:shipIdKeys[number - 1]];
	if(![nDockShipId isKindOfClass:[NSNumber class]]) return nil;
	if([nDockShipId integerValue] == 0) return nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", nDockShipId];
	[request setPredicate:predicate];
	
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:NULL];
	if([array count] == 0) return @"Unknown";
	
	NSString *name = [array[0] valueForKeyPath:@"master_ship.name"];
	return name;
}
- (NSString *)nDock1ShipName
{
	return [self shipNameForNDockNumber:1];
}
- (NSString *)nDock2ShipName
{
	return [self shipNameForNDockNumber:2];
}
- (NSString *)nDock3ShipName
{
	return [self shipNameForNDockNumber:3];
}
- (NSString *)nDock4ShipName
{
	return [self shipNameForNDockNumber:4];
}

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
- (void)notifyIfNeededFinishDockingNumber:(NSUInteger)number
{
	static NSArray *timeKeys = nil;
	if(!timeKeys) {
		timeKeys = @[@"nDock1Time", @"nDock2Time", @"nDock3Time", @"nDock4Time"];
	}
	static NSArray *notifiedKeys = nil;
	if(!notifiedKeys) {
		notifiedKeys = @[@"nDock1Notified", @"nDock2Notified", @"nDock3Notified", @"nDock4Notified"];
	}
	
	NSTimeInterval time = [[self valueForKey:timeKeys[number - 1]] doubleValue];
	
	if(time < 1 * 60 - [[NSTimeZone systemTimeZone] secondsFromGMT]) {
		BOOL flag = [[self valueForKey:notifiedKeys[number -1]] boolValue];
		if(!flag) {
			NSUserNotification * notification = [NSUserNotification new];
			NSString *format = NSLocalizedString(@"%@ Will Finish Docking.", @"%@ Will Finish Docking.");
			notification.title = [NSString stringWithFormat:format, [self shipNameForNDockNumber:number]];
			notification.informativeText = [NSString stringWithFormat:format, [self shipNameForNDockNumber:number]];
			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
			[self setValue:@YES forKey:notifiedKeys[number - 1]];
		}
	} else {
		[self setValue:@NO forKey:notifiedKeys[number - 1]];
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
	self.nDock1Time = [self nDockTimeForNDock:self.nDock1];
	self.nDock2Time = [self nDockTimeForNDock:self.nDock2];
	self.nDock3Time = [self nDockTimeForNDock:self.nDock3];
	self.nDock4Time = [self nDockTimeForNDock:self.nDock4];
	[self checkNameForKey:@"nDock1ShipName" flagKey:@"nDock1Flag" timeValue:self.nDock1Time];
	[self checkNameForKey:@"nDock2ShipName" flagKey:@"nDock2Flag" timeValue:self.nDock2Time];
	[self checkNameForKey:@"nDock3ShipName" flagKey:@"nDock3Flag" timeValue:self.nDock3Time];
	[self checkNameForKey:@"nDock4ShipName" flagKey:@"nDock4Flag" timeValue:self.nDock4Time];
	
	[self notifyIfNeededFinishDockingNumber:1];
	[self notifyIfNeededFinishDockingNumber:2];
	[self notifyIfNeededFinishDockingNumber:3];
	[self notifyIfNeededFinishDockingNumber:4];
	
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
