//
//  HMAnchorageRepairManager.m
//  KCD
//
//  Created by Hori,Masaki on 2015/07/19.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMAnchorageRepairManager.h"

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"

#import "HMServerDataStore.h"
#import "HMKCDeck+Extension.h"
#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterShipObject.h"
#import "HMKCSlotItemObject+Extensions.h"
#import "HMKCMasterSlotItemObject.h"
#import "HMKCMasterSType.h"


@interface HMAnchorageRepairManager ()


@property (strong) NSDate *repairTime;

@property (strong) HMKCDeck* fleet;
@property (strong) NSNumber *deckID;
@property (strong) NSArray<HMKCShipObject *> *members;

@property (strong) NSObjectController *fleetController;
@property (strong) NSArrayController *memberController;

@end

@implementation HMAnchorageRepairManager

static NSMutableArray *sRepairableDeckIDs;

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sRepairableDeckIDs = [NSMutableArray new];
	});
}

- (instancetype)initWithDeck:(HMKCDeck *)deck
{
	self = [super init];
	if(self) {
		_fleet = deck;
		_deckID = _fleet.id;
		
		_fleetController = [NSObjectController new];
		_fleetController.managedObjectContext = deck.managedObjectContext;
		_fleetController.entityName = @"Deck";
		_fleetController.fetchPredicate = [NSPredicate predicateWithFormat:@"id = %@", deck.id];
		NSError *error = nil;
		[_fleetController fetchWithRequest:nil merge:NO error:&error];
		if(error) {
			NSLog(@"%@", error);
		}
		
		[self.fleetController addObserver:self
							  forKeyPath:@"selection.ship_0"
								 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
								 context:@"0"];
		[self.fleetController addObserver:self
							   forKeyPath:@"selection.ship_1"
								  options:0
								  context:@"1"];
		[self.fleetController addObserver:self
							   forKeyPath:@"selection.ship_2"
								  options:0
								  context:@"2"];
		[self.fleetController addObserver:self
							   forKeyPath:@"selection.ship_3"
								  options:0
								  context:@"3"];
		[self.fleetController addObserver:self
							   forKeyPath:@"selection.ship_4"
								  options:0
								  context:@"4"];
		[self.fleetController addObserver:self
							   forKeyPath:@"selection.ship_5"
								  options:0
								  context:@"5"];
		
		[self buildMembers];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(didRecivePortAPINotification:)
				   name:HMPortAPIRecieveNotification
				 object:nil];
		
		
		_memberController = [[NSArrayController alloc] initWithContent:nil];
		[_memberController bind:NSContentArrayBinding
					   toObject:self
					withKeyPath:@"members"
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
	NSArray *shipKeys = @[@"ship_0", @"ship_1", @"ship_2", @"ship_3", @"ship_4", @"ship_5"];
	for (NSString *key in shipKeys) {
		[_fleetController removeObserver:self
							  forKeyPath:[NSString stringWithFormat:@"selection.%@", key]];
	}
	
	[_memberController removeObserver:self forKeyPath:@"arrangedObjects.equippedItem"];
	[_memberController unbind:@"members"];
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
	if([contextObject isKindOfClass:[NSString class]]) {
		[self resetRepairTime];
		[self buildMembers];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change	context:context];
}

- (void)buildMembers
{
	NSMutableArray<HMKCShipObject *> *array = [NSMutableArray array];
	for(NSInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self.fleet[i];
		if(ship) [array addObject:ship];
	}
	self.members = array;
}

- (void)didRecivePortAPINotification:(NSNotification *)notification
{
	NSDate *finishDate = [self.repairTime dateByAddingTimeInterval:20 * 60];
	if([finishDate compare:[NSDate dateWithTimeIntervalSinceNow:0.0]] == NSOrderedAscending) {
		[self resetRepairTime];
	}
}

- (HMKCShipObject *)flagShip
{
	if(self.members.count == 0) return nil;
	return self.members[0];
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
	HMKCShipObject *flagShip = self.flagShip;
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
	HMKCShipObject *flagShip = self.flagShip;
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
