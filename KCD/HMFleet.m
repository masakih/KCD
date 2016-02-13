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
		
		_deckController = [NSObjectController new];
		_deckController.entityName = @"Deck";
		_deckController.managedObjectContext = [[HMServerDataStore defaultManager] managedObjectContext];
		_deckController.fetchPredicate = [NSPredicate predicateWithFormat:@"id = %@", fleetNumber];
		[_deckController fetch:nil];
		
		[self bind:@"deck"
		  toObject:self.deckController
	   withKeyPath:@"content"
		   options:nil];
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

@end
