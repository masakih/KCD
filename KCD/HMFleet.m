//
//  HMFleet.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/11.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMFleet.h"

#import "HMServerDataStore.h"

#import "HMKCDeck+Extension.h"
#import "HMKCShipObject+Extensions.h"



static void *DeckContext = &DeckContext;
static void *ShipContext = &ShipContext;

@interface HMFleet ()
@property (strong) NSNumber *fleetNumber;
@property (strong) NSObjectController *deckController;
@property (weak) HMKCDeck *deck;

@property (readonly) NSArray<NSString *> *deckObserveKeys;

@property (copy) NSArray<HMKCShipObject *> *ships;
@property (readonly) NSArray<NSString *> *shipObserveKeys;

@end
@implementation HMFleet

+ (instancetype)fleetWithNumber:(NSNumber *)fleetNumber
{
	return [[self alloc] initWithNumber:fleetNumber];
}
- (instancetype)initWithNumber:(NSNumber *)fleetNumber
{
	self = [super init];
	if(self) {
		if(fleetNumber.integerValue < 1 || fleetNumber.integerValue > 4) {
			return nil;
		}
		_fleetNumber = fleetNumber;
		
		_deckController = [[NSObjectController alloc] initWithContent:nil];
		_deckController.entityName = @"Deck";
		_deckController.managedObjectContext = [[HMServerDataStore defaultManager] managedObjectContext];
		_deckController.fetchPredicate = [NSPredicate predicateWithFormat:@"id = %@", fleetNumber];
		NSFetchRequest *request = [NSFetchRequest new];
		request.entity = [NSEntityDescription entityForName:@"Deck"
									 inManagedObjectContext:[HMServerDataStore defaultManager].managedObjectContext];
		request.predicate = _deckController.fetchPredicate;
		[_deckController fetchWithRequest:request
									merge:NO
									error:NULL];
		
		self.deck = _deckController.content;
		for(NSString *key in self.deckObserveKeys) {
			[_deckController addObserver:self
							  forKeyPath:key
								 options:0
								 context:DeckContext];
		}
	}
	
	return self;
}
- (void)dealloc
{
	for(NSString *key in self.deckObserveKeys) {
		[_deckController removeObserver:self forKeyPath:key];
	}
	for(HMKCShipObject *ship in _ships) {
		for(NSString *key in self.shipObserveKeys) {
			[ship removeObserver:self forKeyPath:key];
		}
	}
}

- (instancetype)self
{
	return self;
}

- (NSArray<NSString *> *)deckObserveKeys
{
	return  [NSArray arrayWithObjects:
			 @"selection.ship_0",
			 @"selection.ship_1",
			 @"selection.ship_2",
			 @"selection.ship_3",
			 @"selection.ship_4",
			 @"selection.ship_5",
			 nil];
}
-(NSArray<NSString *> *)shipObserveKeys
{
	return  [NSArray arrayWithObjects:
			 @"sakuteki_0",
			 @"seiku",
			 @"lv",
			 @"totalDrums",
			 nil];
}

- (HMKCShipObject *)objectAtIndexedSubscript:(NSUInteger)idx
{
	return self.deck[idx];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if(context == DeckContext) {
		
		for(HMKCShipObject *ship in _ships) {
			for(NSString *key in self.shipObserveKeys) {
				[ship removeObserver:self forKeyPath:key];
			}
		}
		
		NSMutableArray<HMKCShipObject *> *result = [NSMutableArray array];
		
		for(NSUInteger i = 0; i < 6; i++) {
			HMKCShipObject *ship = self[i];
			if(ship) {
				[result addObject:ship];
			}
		}
		
		[self willChangeValueForKey:@"totalSakuteki"];
		[self willChangeValueForKey:@"totalSeiku"];
		[self willChangeValueForKey:@"totalCalclatedSeiku"];
		[self willChangeValueForKey:@"totalLevel"];
		[self willChangeValueForKey:@"totalDrums"];
		
		self.ships = result;
		
		[self didChangeValueForKey:@"totalDrums"];
		[self didChangeValueForKey:@"totalLevel"];
		[self willChangeValueForKey:@"totalCalclatedSeiku"];
		[self didChangeValueForKey:@"totalSeiku"];
		[self didChangeValueForKey:@"totalSakuteki"];
		
		
		for(HMKCShipObject *ship in _ships) {
			for(NSString *key in self.shipObserveKeys) {
				[ship addObserver:self
					   forKeyPath:key
						  options:0
						  context:ShipContext];
			}
		}
		
		return;
	}
	
	if(context == ShipContext) {
		if([keyPath isEqualToString:@"sakuteki_0"]) {
			[self willChangeValueForKey:@"totalSakuteki"];
			[self didChangeValueForKey:@"totalSakuteki"];
		}
		if([keyPath isEqualToString:@"seiku"]) {
			[self willChangeValueForKey:@"totalSeiku"];
			[self didChangeValueForKey:@"totalSeiku"];
			
			[self willChangeValueForKey:@"totalCalclatedSeiku"];
			[self didChangeValueForKey:@"totalCalclatedSeiku"];
		}
		if([keyPath isEqualToString:@"lv"]) {
			[self willChangeValueForKey:@"totalLevel"];
			[self didChangeValueForKey:@"totalLevel"];
		}
		if([keyPath isEqualToString:@"totalDrums"]) {
			[self willChangeValueForKey:@"totalDrums"];
			[self didChangeValueForKey:@"totalDrums"];
		}
		
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

+ (NSSet *)keyPathsForValuesAffectingFlagShip
{
	return [NSSet setWithObject:@"deck.ship_0"];
}
- (HMKCShipObject *)flagShip
{
	return self[0];
}
+ (NSSet *)keyPathsForValuesAffectingSecondShip
{
	return [NSSet setWithObject:@"deck.ship_1"];
}
- (HMKCShipObject *)secondShip
{
	return self[1];
}
+ (NSSet *)keyPathsForValuesAffectingThirdShip
{
	return [NSSet setWithObject:@"deck.ship_2"];
}
- (HMKCShipObject *)thirdShip
{
	return self[2];
}
+ (NSSet *)keyPathsForValuesAffectingFourthShip
{
	return [NSSet setWithObject:@"deck.ship_3"];
}
- (HMKCShipObject *)fourthShip
{
	return self[3];
}
+ (NSSet *)keyPathsForValuesAffectingFifthShip
{
	return [NSSet setWithObject:@"deck.ship_4"];
}
- (HMKCShipObject *)fifthShip
{
	return self[4];
}
+ (NSSet *)keyPathsForValuesAffectingSixthShip
{
	return [NSSet setWithObject:@"deck.ship_5"];
}
- (HMKCShipObject *)sixthShip
{
	return self[5];
}

+ (NSSet *)keyPathsForValuesAffectingName
{
	return [NSSet setWithObject:@"deck.name"];
}
- (NSString *)name
{
	NSString *name = self.deck.name;
	
	return name;
}

+ (NSSet *)keyPathsForValuesAffectingId
{
	return [NSSet setWithObject:@"deck.id"];
}
- (NSNumber *)id
{
	return self.deck.id;
}

- (NSNumber *)totalSakuteki
{
	NSInteger total = 0;
	for(NSInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self[i];
		total += ship.sakuteki_0.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalSeiku
{
	NSInteger total = 0;
	for(NSInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self[i];
		total += ship.seiku.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalCalclatedSeiku
{
	NSInteger total = 0;
	for(NSInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self[i];
		total += ship.totalSeiku.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalLevel
{
	NSInteger total = 0;
	for(NSInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self[i];
		total += ship.lv.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalDrums
{
	NSInteger total = 0;
	for(NSInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self[i];
		total += ship.totalDrums.integerValue;
	}
	return @(total);
}
@end
