//
//  HMNyukyoDockStatus.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMNyukyoDockStatus.h"

#import "HMServerDataStore.h"
#import "HMUserDefaults.h"


enum {
	kNoShip = 0,
	kHasShip = 1,
};

@interface HMNyukyoDockStatus ()
@property (strong) NSArrayController *controller;

@property (strong, readwrite) NSString *name;
@property (strong, readwrite) NSNumber *time;
@property (readwrite) BOOL didNotify;

@end


@implementation HMNyukyoDockStatus

- (id)initWithDockNumber:(NSInteger)dockNumber
{
	self = [super init];
	
	if(dockNumber < 1 || dockNumber > 4) {
		self = nil;
		return nil;
	}
	
	if(self) {
		_controller = [NSArrayController new];
		[self.controller setManagedObjectContext:[HMServerDataStore defaultManager].managedObjectContext];
		[self.controller setEntityName:@"NyukyoDock"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", dockNumber];
		[self.controller setFetchPredicate:predicate];
		[self.controller setAutomaticallyRearrangesObjects:YES];
		[self.controller fetch:nil];
		
		[self.controller addObserver:self
						 forKeyPath:@"selection.state"
							options:0
							context:NULL];
	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selection.state"]) {
		[self updataStatus];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)update
{
	if(!self.name) {
		self.time = nil;
		return;
	}
	
	NSNumber *compTimeValue = [self.controller valueForKeyPath:@"selection.complete_time"];
	if(![compTimeValue isKindOfClass:[NSNumber class]]) {
		self.name = nil;
		self.time = nil;
		return;
	}
	
	NSTimeInterval compTime = (NSUInteger)([compTimeValue doubleValue] / 1000.0);
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	
	if(diff < 0) {
		self.time = @(0);
	} else {
		self.time =  @(diff);
	}
	
	if(!self.didNotify) {
		if(diff < 1 * 60) {
			NSUserNotification * notification = [NSUserNotification new];
			NSString *format = NSLocalizedString(@"%@ Will Finish Docking.", @"%@ Will Finish Docking.");
			notification.title = [NSString stringWithFormat:format, self.name];
			notification.informativeText = notification.title;
			if(HMStandardDefaults.playFinishNyukyoSound) {
				notification.soundName = NSUserNotificationDefaultSoundName;
			}
			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
			
			self.didNotify = YES;
		}
	}
}

- (void)updataStatus
{
	NSInteger status = [[self.controller valueForKeyPath:@"selection.state"] integerValue];
	if(status == kNoShip) {
		self.didNotify = NO;
		self.name = nil;
		self.time = nil;
		return;
	}
	
	NSNumber *nDockShipId = [self.controller valueForKeyPath:@"selection.ship_id"];
	if(![nDockShipId isKindOfClass:[NSNumber class]]) return;
	if([nDockShipId integerValue] == 0) return;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", nDockShipId];
	[request setPredicate:predicate];
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:NULL];
	if([array count] == 0) {
		[self performSelector:_cmd withObject:nil afterDelay:0.33];
		self.name = @"Unknown";
		return;
	}
	
	NSString *newName = [array[0] valueForKeyPath:@"master_ship.name"];
	if(![newName isEqualToString:self.name]) {
		self.name = newName;
	}
}

@end
