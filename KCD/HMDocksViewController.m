//
//  HMDocksViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDocksViewController.h"

#import "HMCoreDataManager.h"

@interface HMDocksViewController ()


// 入渠中フラグ
@property BOOL nDock1Flag;
@property BOOL nDock2Flag;
@property BOOL nDock3Flag;
@property BOOL nDock4Flag;

// 遠征中フラグ
@property BOOL deck2Flag;
@property BOOL deck3Flag;
@property BOOL deck4Flag;


// NSUserNotifyを行ったか
@property BOOL deck2Notified;
@property BOOL deck3Notified;
@property BOOL deck4Notified;

@property BOOL nDock1Notified;
@property BOOL nDock2Notified;
@property BOOL nDock3Notified;
@property BOOL nDock4Notified;

@property BOOL kDock1Notified;
@property BOOL kDock2Notified;
@property BOOL kDock3Notified;
@property BOOL kDock4Notified;

@end

@implementation HMDocksViewController


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
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
- (void)notifyReturnFromMission:(NSUInteger)number
{
	NSArray *notifiedKeys = @[@"deck2Notified", @"deck3Notified", @"deck4Notified"];
	NSArray *timeKeys = @[@"deck2Time", @"deck3Time", @"deck4Time"];
	NSArray *nameKeys = @[@"mission2Name", @"mission3Name", @"mission4Name"];
	NSArray *fleetNameKeys = @[@"deck2.selection.name", @"deck3.selection.name", @"deck4.selection.name"];
	
	NSTimeInterval time = [[self valueForKey:timeKeys[number - 2]] doubleValue];
	BOOL didNotified = [[self valueForKey:notifiedKeys[number - 2]] boolValue];
	
	if(!didNotified && time < 1 * 60 - [[NSTimeZone systemTimeZone] secondsFromGMT]) {
		NSString *missionName = [self valueForKey:nameKeys[number - 2]];
		NSString *fleetName = [self valueForKeyPath:fleetNameKeys[number - 2]];
		
		NSUserNotification * notification = [NSUserNotification new];
		NSString *format = NSLocalizedString(@"%@ Will Return From Mission.", @"%@ Will Return From Mission.");
		notification.title = [NSString stringWithFormat:format, fleetName];
		format = NSLocalizedString(@"%@ Will Return From %@.", @"%@ Will Return From %@.");
		notification.informativeText = [NSString stringWithFormat:format, fleetName, missionName];
		[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		
		[self setValue:@YES forKey:notifiedKeys[number - 2]];
	}
}

- (NSString *)missionNameForDeckNumber:(NSUInteger)number
{
	NSArray *areaIdKeys = @[@"deck2.selection.mission_1", @"deck3.selection.mission_1", @"deck4.selection.mission_1"];
	NSArray *notifiedKeys = @[@"deck2Notified", @"deck3Notified", @"deck4Notified"];
	NSArray *flagKeys = @[@"deck2Flag", @"deck3Flag", @"deck4Flag"];

	NSNumber *areaId = [self valueForKeyPath:areaIdKeys[number - 2]];
	if(![areaId isKindOfClass:[NSNumber class]]) {
		[self setValue:@NO forKey:notifiedKeys[number - 2]];
		[self setValue:@NO forKey:flagKeys[number - 2]]; 
		return nil;
	}
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MasterMission"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", areaId];
	[request setPredicate:predicate];
	
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:NULL];
	if([array count] == 0) {
		[self setValue:@NO forKey:notifiedKeys[number - 2]];
		[self setValue:@NO forKey:flagKeys[number - 2]];
		return nil;
	}
	
	NSString *name = [array[0] valueForKey:@"name"];
	return name;
}
- (NSString *)mission2Name
{
	return [self missionNameForDeckNumber:2];
}
- (NSString *)mission3Name
{
	return [self missionNameForDeckNumber:3];
}
- (NSString *)mission4Name
{
	return [self missionNameForDeckNumber:4];
}
- (NSNumber *)missionTimeForDeck:(NSObjectController *)deck
{
	NSNumber *compTimeValue = [deck valueForKeyPath:@"selection.mission_2"];
	if(![compTimeValue isKindOfClass:[NSNumber class]]) return nil;
	if([compTimeValue isEqualToNumber:@0]) return nil;
	
	NSTimeInterval compTime = (NSUInteger)([compTimeValue doubleValue] / 1000.0);
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	
	if(diff < 0) {
		return @( - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	} else {
		return @(diff - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	}
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
	NSArray *shipIdKeys = @[@"nDock1.selection.ship_id", @"nDock2.selection.ship_id", @"nDock3.selection.ship_id", @"nDock4.selection.ship_id"];
	
	NSNumber *nDockShipId = [self valueForKeyPath:shipIdKeys[number - 1]];
	if(![nDockShipId isKindOfClass:[NSNumber class]]) return nil;
	if([nDockShipId integerValue] == 0) return nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", nDockShipId];
	[request setPredicate:predicate];
	
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:NULL];
	if([array count] == 0) return nil;
	
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
	NSNumber *item1 =[nDock valueForKeyPath:@"selection.item1"];
	if(![item1 isKindOfClass:[NSNumber class]]) return nil;
	if([item1 isEqualToNumber:@0]) return nil;
	
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
	NSArray *timeKeys = @[@"nDock1Time", @"nDock2Time", @"nDock3Time", @"nDock4Time"];
	NSArray *notifiedKeys = @[@"nDock1Notified", @"nDock2Notified", @"nDock3Notified", @"nDock4Notified"];
	
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
	NSArray *timeKeys = @[@"kDock1Time", @"kDock2Time", @"kDock3Time", @"kDock4Time"];
	NSArray *notifiedKeys = @[@"kDock1Notified", @"kDock2Notified", @"kDock3Notified", @"kDock4Notified"];
	
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
	self.deck2Time = [self missionTimeForDeck:self.deck2];
	self.deck3Time = [self missionTimeForDeck:self.deck3];
	self.deck4Time = [self missionTimeForDeck:self.deck4];
	[self checkNameForKey:@"mission2Name" flagKey:@"deck2Flag" timeValue:self.deck2Time];
	[self checkNameForKey:@"mission3Name" flagKey:@"deck3Flag" timeValue:self.deck3Time];
	[self checkNameForKey:@"mission4Name" flagKey:@"deck4Flag" timeValue:self.deck4Time];
	
	[self notifyReturnFromMission:2];
	[self notifyReturnFromMission:3];
	[self notifyReturnFromMission:4];
}

@end
