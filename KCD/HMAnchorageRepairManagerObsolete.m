//
//  HMAnchorageRepairManager.m
//  KCD
//
//  Created by Hori,Masaki on 2015/07/19.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMAnchorageRepairManagerObsolete.h"

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"

#import "HMFleet.h"

#import "HMServerDataStore.h"
#import "HMKCDeck+Extension.h"
#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterShipObject.h"
#import "HMKCSlotItemObject+Extensions.h"
#import "HMKCMasterSlotItemObject.h"
#import "HMKCMasterSType.h"


@interface HMAnchorageRepairManagerObsolete ()

@property (strong) NSDate *repairTime;

@property (strong) HMFleet *fleet;

@property (strong) NSNumber *deckID;

@property (strong) NSObjectController *fleetController;
@property (strong) NSArrayController *memberController;

@end

@implementation HMAnchorageRepairManagerObsolete

static NSMutableArray *sRepairableDeckIDs;

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sRepairableDeckIDs = [NSMutableArray new];
	});
}

+ (instancetype)anchorageRepairManagerWithFleet:(HMFleet *)fleet
{
	return [[self alloc] initWithFleet:fleet];
}
- (instancetype)initWithFleet:(HMFleet *)fleet
{
	self = [super init];
	if(self) {
		_fleet = fleet;
		_deckID = fleet.id;
		
		_fleetController = [[NSObjectController alloc] initWithContent:fleet];
		[self.fleetController addObserver:self
							   forKeyPath:@"selection.ships"
								  options:0
								  context:@"ships"];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(didRecivePortAPINotification:)
				   name:HMPortAPIRecieveNotification
				 object:nil];
		
		_memberController = [[NSArrayController alloc] initWithContent:nil];
		[_memberController bind:NSContentArrayBinding
					   toObject:self.fleet
					withKeyPath:@"ships"
						options:nil];
		[self.memberController addObserver:self
								forKeyPath:@"arrangedObjects.equippedItem"
								   options:0
								   context:@"members"];
	}
	
	return self;
}

- (void)dealloc
{
	[_fleetController removeObserver:self
						  forKeyPath:@"selection.ships"];
	
	[_memberController removeObserver:self forKeyPath:@"arrangedObjects.equippedItem"];
	[_memberController unbind:@"ships"];
}

- (NSDate *)repairTime
{
	if(!self.repairable) return nil;
	
	return HMStandardDefaults.repairTime;;
}
- (void)setRepairTime:(NSDate *)repairTime
{
	HMStandardDefaults.repairTime = repairTime;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	id contextObject = (__bridge id)(context);
	
	if([contextObject isEqual:@"members"]) {
		[self willChangeValueForKey:@"repairableShipCount"];
		[self didChangeValueForKey:@"repairableShipCount"];
		return;
	}
	if([contextObject isEqual:@"ships"]) {
		[self resetRepairTime];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change	context:context];
}

- (void)didRecivePortAPINotification:(NSNotification *)notification
{
	NSDate *finishDate = [self.repairTime dateByAddingTimeInterval:20 * 60];
	if([finishDate compare:[NSDate dateWithTimeIntervalSinceNow:0.0]] == NSOrderedAscending) {
		[self resetRepairTime];
	}
}

- (NSArray *)repairShipIds
{
	return @[@(19)];
}
- (NSArray *)repairSlotItemIds
{
	return @[@(31)];
}
- (BOOL)repairable
{
	HMKCShipObject *flagShip = self.fleet[0];
	HMKCMasterShipObject *flagShipMaster = flagShip.master_ship;
	HMKCMasterSType *stype = flagShipMaster.stype;
	NSNumber *stypeId = stype.id;
	BOOL result = [self.repairShipIds containsObject:stypeId];
	if(!result && [sRepairableDeckIDs containsObject:self.deckID]) {
		[sRepairableDeckIDs removeObject:self.deckID];
	} else if(result && ![sRepairableDeckIDs containsObject:self.deckID]) {
		[sRepairableDeckIDs addObject:self.deckID];
	}
	return result;
}

- (NSNumber *)repairableShipCount
{
	if(![self repairable]) return @0;
	
	NSUInteger count = 2;
	HMKCShipObject *flagShip = self.fleet[0];
	for(HMKCSlotItemObject *item in flagShip.equippedItem) {
		if([self.repairSlotItemIds containsObject:item.master_slotItem.type_2]) {
			count++;
		}
	}
	return @(count);
}

- (void)resetRepairTime
{
	BOOL prevRepairable = [sRepairableDeckIDs containsObject:self.deckID];
	if(!prevRepairable && !self.repairable) return;
	
	if(self.repairable) {
		self.repairTime = [NSDate dateWithTimeIntervalSinceNow:0.0];
	} else {
		self.repairTime = nil;
	}
}


@end
