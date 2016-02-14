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

@interface HMFleet ()
@property (strong) NSNumber *fleetNumber;
@property (strong) NSObjectController *deckController;
@property (weak) HMKCDeck *deck;

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
	}
	
	return self;
}

- (instancetype)self
{
	return self;
}

- (HMKCShipObject *)objectAtIndexedSubscript:(NSUInteger)idx
{
	return self.deck[idx];
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

+ (NSSet *)keyPathsForValuesAffectingShips
{
	return [NSSet setWithObjects:
			@"deck",
			@"deck.ship_0",
			@"deck.ship_1",
			@"deck.ship_2",
			@"deck.ship_3",
			@"deck.ship_4",
			@"deck.ship_5",
			nil];
}
- (NSArray<HMKCShipObject *> *)ships
{
	NSMutableArray<HMKCShipObject *> *result = [NSMutableArray array];
	
	for(NSUInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self[i];
		if(ship) {
			[result addObject:ship];
		}
	}
	return result;
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

 +(NSSet *)keyPathsForValuesAffectingId
{
	return [NSSet setWithObject:@"deck.id"];
}
- (NSNumber *)id
{
	return self.deck.id;
}

+ (NSSet *)keyPathsForValuesAffectingTotalSakuteki
{
	return [NSSet setWithObjects:
			@"flagShip.sakuteki_0",
			@"secondShip.sakuteki_0",
			@"thirdShip.sakuteki_0",
			@"fourthShip.sakuteki_0",
			@"fifthShip.sakuteki_0",
			@"sixthShip.sakuteki_0",
			nil];
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

+ (NSSet *)keyPathsForValuesAffectingTotalSeiku
{
	return [NSSet setWithObjects:
			@"flagShip.seiku",
			@"secondShip.seiku",
			@"thirdShip.seiku",
			@"fourthShip.seiku",
			@"fifthShip.seiku",
			@"sixthShip.seiku",
			nil];
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
+ (NSSet *)keyPathsForValuesAffectingTotalCalclatedSeiku
{
	return [NSSet setWithObjects:
			@"flagShip.seiku",
			@"secondShip.seiku",
			@"thirdShip.seiku",
			@"fourthShip.seiku",
			@"fifthShip.seiku",
			@"sixthShip.seiku",
			nil];
}
- (NSNumber *)totalCalclatedSeiku
{
	NSInteger total = 0;
	for(NSInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self[i];
		total += ship.seiku.integerValue;
		total += ship.extraSeiku.integerValue;
	}
	return @(total);
}
+ (NSSet *)keyPathsForValuesAffectingTotalLevel
{
	return [NSSet setWithObjects:
			@"flagShip.lv",
			@"secondShip.lv",
			@"thirdShip.lv",
			@"fourthShip.lv",
			@"fifthShip.lv",
			@"sixthShip.lv",
			nil];
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
+ (NSSet *)keyPathsForValuesAffectingTotalDrums
{
	return [NSSet setWithObjects:
			@"flagShip.totalDrums",
			@"secondShip.totalDrums",
			@"thirdShip.totalDrums",
			@"fourthShip.totalDrums",
			@"fifthShip.totalDrums",
			@"sixthShip.totalDrums",
			nil];
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
