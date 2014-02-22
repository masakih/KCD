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
@property BOOL deck2Flag;
@property BOOL deck3Flag;
@property BOOL deck4Flag;


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

- (NSNumber *)nDockTimeForNDock:(NSObjectController *)nDock
{
	NSNumber *item1 =[nDock valueForKeyPath:@"selection.item1"];
	if(![item1 isKindOfClass:[NSNumber class]]) return nil;
	if([item1 isEqualToNumber:@0]) return nil;
	
	NSNumber *compTimeValue = [nDock valueForKeyPath:@"selection.complete_time"];
	if(![compTimeValue isKindOfClass:[NSNumber class]]) return nil;
//	if([compTimeValue isEqualToNumber:@0]) return nil;
	
	NSTimeInterval compTime = (NSUInteger)([compTimeValue doubleValue] / 1000.0);
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	
	if(diff < 0) {
		return @( - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	} else {
		return @(diff - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	}
}

- (NSString *)mission2Name
{
	NSArray *array = [self.deck2 valueForKeyPath:@"selection.missionName.name"];
	if(![array isKindOfClass:[NSArray class]] || [array count] == 0) {
		self.deck2Flag = NO;
		return nil;
	}
	
	NSString *name = array[0];
	if(name && !self.deck2Flag) {
		self.deck2Flag = YES;
	}
	return name;
}
- (NSString *)mission3Name
{
	NSArray *array = [self.deck3 valueForKeyPath:@"selection.missionName.name"];
	if(![array isKindOfClass:[NSArray class]] || [array count] == 0) {
		self.deck3Flag = NO;
		return nil;
	}
	
	NSString *name = array[0];
	if(name && !self.deck3Flag) {
		self.deck3Flag = YES;
	}
	return name;
}
- (NSString *)mission4Name
{
	NSArray *array = [self.deck4 valueForKeyPath:@"selection.missionName.name"];
	if(![array isKindOfClass:[NSArray class]] || [array count] == 0) {
		self.deck4Flag = NO;
		return nil;
	}
	
	NSString *name = array[0];
	if(name && !self.deck4Flag) {
		self.deck4Flag = YES;
	}
	return name;
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
- (void)checkMission:(id)timeValue flagKey:(NSString *)flagKey nameKey:(NSString *)nameKey
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
- (void)fire:(id)timer
{
	self.nDock1Time = [self nDockTimeForNDock:self.nDock1];
	self.nDock2Time = [self nDockTimeForNDock:self.nDock2];
	self.nDock3Time = [self nDockTimeForNDock:self.nDock3];
	self.nDock4Time = [self nDockTimeForNDock:self.nDock4];
	
	self.kDock1Time = [self nDockTimeForNDock:self.kDock1];
	self.kDock2Time = [self nDockTimeForNDock:self.kDock2];
	self.kDock3Time = [self nDockTimeForNDock:self.kDock3];
	self.kDock4Time = [self nDockTimeForNDock:self.kDock4];
	
	self.deck2Time = [self missionTimeForDeck:self.deck2];
	self.deck3Time = [self missionTimeForDeck:self.deck3];
	self.deck4Time = [self missionTimeForDeck:self.deck4];
	[self checkMission:self.deck2Time flagKey:@"deck2Flag" nameKey:@"mission2Name"];
	[self checkMission:self.deck3Time flagKey:@"deck3Flag" nameKey:@"mission3Name"];
	[self checkMission:self.deck4Time flagKey:@"deck4Flag" nameKey:@"mission4Name"];
}
@end
