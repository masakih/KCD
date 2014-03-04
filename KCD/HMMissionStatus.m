//
//  HMMissionStatus.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/02.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMissionStatus.h"

#import "HMCoreDataManager.h"


enum {
	kNoMission = 0,
	kHasMission = 1,
	kFinishMission = 2,
};

@interface HMMissionStatus ()
@property (strong) NSArrayController *contoller;

@property (strong, readwrite) NSString *name;
@property (strong, readwrite) NSNumber *time;
@property (readwrite) BOOL isTasking;
@property (readwrite) BOOL didNotify;

@property BOOL prevStatusFinish;

@end

@implementation HMMissionStatus

- (id)initWithDeckNumber:(NSUInteger)deckNumber
{
	self = [super init];
	
	if(deckNumber == 1 || deckNumber > 4) {
		self = nil;
		return nil;
	}
	
	if(self) {
		_contoller = [NSArrayController new];
		[self.contoller setManagedObjectContext:[HMCoreDataManager defaultManager].managedObjectContext];
		[self.contoller setEntityName:@"Deck"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", deckNumber];
		[self.contoller setFetchPredicate:predicate];
		[self.contoller setAutomaticallyRearrangesObjects:YES];
		[self.contoller fetch:nil];
		
		[self.contoller addObserver:self
						 forKeyPath:@"selection.mission_0"
							options:0
							context:NULL];
	}
	
	return self;
}

- (void)update
{
	if(!self.isTasking) {
		if(self.time) self.time = nil;
		return;
	}
	
	NSNumber *compTimeValue = [self.contoller valueForKeyPath:@"selection.mission_2"];
	if(![compTimeValue isKindOfClass:[NSNumber class]]) return;
	if([compTimeValue isEqualToNumber:@0]) return;
	NSTimeInterval compTime = (NSUInteger)([compTimeValue doubleValue] / 1000.0);
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	NSNumber *returnValue = nil;
	if(diff < 0) {
		returnValue = @( - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	} else {
		returnValue = @(diff - [[NSTimeZone systemTimeZone] secondsFromGMT]);
	}
	
	if(!self.didNotify) {
		if(diff < 1 * 60) {
			NSString *fleetName = [self.contoller valueForKeyPath:@"selection.name"];
			
			NSUserNotification * notification = [NSUserNotification new];
			NSString *format = NSLocalizedString(@"%@ Will Return From Mission.", @"%@ Will Return From Mission.");
			notification.title = [NSString stringWithFormat:format, fleetName];
			format = NSLocalizedString(@"%@ Will Return From %@.", @"%@ Will Return From %@.");
			notification.informativeText = [NSString stringWithFormat:format, fleetName, self.name];
			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
			
			self.didNotify = YES;
		}
	}
	
	self.time = returnValue;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selection.mission_0"]) {
		NSInteger status = [[self.contoller valueForKeyPath:@"selection.mission_0"] integerValue];
		switch(status) {
			case kNoMission:
				self.name = nil;
				self.prevStatusFinish = NO;
				if(self.isTasking) self.isTasking = NO;
				if(self.didNotify) self.didNotify = NO;
				break;
			case kHasMission:
				[self changeProperty:nil];
				if(!self.prevStatusFinish) {
					if(!self.isTasking) self.isTasking = YES;
				}
				self.prevStatusFinish = NO;
				break;
			case kFinishMission:
				self.name = nil;
				self.prevStatusFinish = YES;
				if(!self.isTasking) self.isTasking = NO;
				break;
			default:
				NSLog(@"Mission status is %ld", status);
				break;
		}
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)changeProperty:(id)dummy
{
	if(self.prevStatusFinish) {
		self.name = nil;
		self.time = nil;
		return;
	}
	
	NSNumber *mission_1 = [self.contoller valueForKeyPath:@"selection.mission_1"];
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MasterMission"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", mission_1];
	[request setPredicate:predicate];
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:NULL];
	if([array count] == 0) {
		[self performSelector:_cmd withObject:nil afterDelay:0.33];
		self.name = @"Unknown";
		return;
	}
	NSString *newName = [array[0] valueForKey:@"name"];
	
	if(![newName isEqualToString:self.name]) {
		self.name = newName;
	}
}

@end
