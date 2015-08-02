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


@interface HMAnchorageRepairManager ()


@property (strong) NSDate *repairTime;

@property (strong) HMKCDeck* fleet;
@property (strong) NSNumber *deckID;
@property (strong) NSArray *members;

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
		
//		[self resetRepairTime];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(didRecivePortAPINotification:)
				   name:HMPortAPIRecieveNotification
				 object:nil];
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
	NSString *observeKeyPath = @"arrangedObjects.equippedItem";
	
	[self.memberController removeObserver:self forKeyPath:observeKeyPath];
	
	NSArray *shipKeys = @[@"ship_0", @"ship_1", @"ship_2", @"ship_3", @"ship_4", @"ship_5"];
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSMutableArray *array = [NSMutableArray new];
	[shipKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
		id shipID = [_fleet valueForKey:key];
		NSError *error = nil;
		NSArray *ships = [store objectsWithEntityName:@"Ship"
												error:&error
									  predicateFormat:@"id = %ld", [shipID integerValue]];
		if(error) {
			NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
		}
		if(ships.count != 0) {
			[array addObject:ships[0]];
		}
	}];
	_members = array;
	_memberController = [[NSArrayController alloc] initWithContent:array];
	[self.memberController addObserver:self
							forKeyPath:observeKeyPath
							   options:0
							   context:@"members"];
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
	id stype = flagShipMaster.stype;
	id stypeId = [stype valueForKey:@"id"];
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
