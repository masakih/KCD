//
//  HMFleetInformation.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/28.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMFleetInformation.h"

#import "HMServerDataStore.h"
#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterSlotItemObject.h"

#import "KCD-Swift.h"

@interface HMFleetInformation ()
@property (strong) NSArray *shipNameKeys;

@property (strong) NSArrayController *deckController;

@property (strong) id selectedFleet;

// overwrite
@property (nonatomic, strong) NSString *name;

@property (readwrite, strong) HMKCShipObject *flagShip;
@property (readwrite, strong) HMKCShipObject *secondShip;
@property (readwrite, strong) HMKCShipObject *thirdShip;
@property (readwrite, strong) HMKCShipObject *fourthShip;
@property (readwrite, strong) HMKCShipObject *fifthShip;
@property (readwrite, strong) HMKCShipObject *sixthShip;
@end

@implementation HMFleetInformation
@synthesize selectedFleetNumber = _selectedFleetNumber;

- (id)init
{
	self = [super init];
	if(self) {
		_shipNameKeys = @[@"flagShip", @"secondShip", @"thirdShip",
						  @"fourthShip", @"fifthShip", @"sixthShip"];
		
		_deckController = [NSArrayController new];
		[_deckController setEntityName:@"Deck"];
		[_deckController setManagedObjectContext:[[HMServerDataStore defaultManager] managedObjectContext]];
		[_deckController setAvoidsEmptySelection:YES];
		[_deckController setPreservesSelection:YES];
		[_deckController setAutomaticallyPreparesContent:YES];
		[_deckController setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
		NSError *error = nil;
		[_deckController fetchWithRequest:nil merge:NO error:&error];
		if(error) {
			NSLog(@"%@", error);
		}
		
		[self.deckController addObserver:self
							  forKeyPath:@"selection.ship_0"
								 options:0
								 context:@"0"];
		[self.deckController addObserver:self
							  forKeyPath:@"selection.ship_1"
								 options:0
								 context:@"1"];
		[self.deckController addObserver:self
							  forKeyPath:@"selection.ship_2"
								 options:0
								 context:@"2"];
		[self.deckController addObserver:self
							  forKeyPath:@"selection.ship_3"
								 options:0
								 context:@"3"];
		[self.deckController addObserver:self
							  forKeyPath:@"selection.ship_4"
								 options:0
								 context:@"4"];
		[self.deckController addObserver:self
							  forKeyPath:@"selection.ship_5"
								 options:0
								 context:@"5"];
		
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	id contextObject = (__bridge id)context;
	
	if([contextObject isKindOfClass:[NSString class]]) {
		[self buildFleet];
		
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)changeShipWithNumber:(NSInteger)shipNumber
{
	id ship = nil;
	NSError *error = nil;
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSString *key = [NSString stringWithFormat:@"ship_%ld", shipNumber];
	NSNumber *shipIdNumber = [self.selectedFleet valueForKey:key];
	NSInteger shipId = [shipIdNumber integerValue];
	NSArray *array = nil;
	if(shipId != -1) {
		array = [store objectsWithEntityName:@"Ship"
									   error:&error
							 predicateFormat:@"id = %ld", shipId];
	}
	if(shipId != -1 && array.count == 0) {
		NSLog(@"Could not found ship of id %@", shipIdNumber);
	} else {
		ship = array[0];
	}
	[self setValue:ship forKey:self.shipNameKeys[shipNumber]];
}
- (void)buildFleet
{
	for(id key in self.shipNameKeys) {
		[self setValue:nil forKey:key];
	}
	self.name = nil;
	
	NSInteger fleetId = [self.selectedFleetNumber integerValue];
	if(fleetId > 6 || fleetId <= 0) {
		return;
	}
	
	NSArray *decks = [self.deckController arrangedObjects];
	if(decks.count == 0) return;
	self.selectedFleet = [decks objectAtIndex:fleetId-1];
	self.name = [self.selectedFleet valueForKey:@"name"];
	
	for(NSInteger i = 0; i < 6; i++) {
		[self changeShipWithNumber:i];
	}
}

+ (NSSet *)keyPathsForValuesAffectingTotalSakuteki
{
	return [NSSet setWithObjects:
			@"flagShip", @"secondShip", @"thirdShip",
			@"fourthShip", @"fifthShip", @"sixthShip",
			@"flagShip.sakuteki_0",
			@"secondShip.sakuteki_0",
			@"thirdShip.sakuteki_0",
			@"fourthShip.sakuteki_0",
			@"fifthShip.sakuteki_0",
			@"sixthShip.sakuteki_0",
			nil];
}
+ (NSSet *)keyPathsForValuesAffectingTotalSeiku
{
	return [NSSet setWithObjects:
			@"flagShip", @"secondShip", @"thirdShip",
			@"fourthShip", @"fifthShip", @"sixthShip",
			@"flagShip.onslot_0",
			@"flagShip.onslot_1",
			@"flagShip.onslot_2",
			@"flagShip.onslot_3",
			@"flagShip.onslot_4",
			
			@"secondShip.onslot_0",
			@"secondShip.onslot_1",
			@"secondShip.onslot_2",
			@"secondShip.onslot_3",
			@"secondShip.onslot_4",
			
			@"thirdShip.onslot_0",
			@"thirdShip.onslot_1",
			@"thirdShip.onslot_2",
			@"thirdShip.onslot_3",
			@"thirdShip.onslot_4",
			
			@"fourthShip.onslot_0",
			@"fourthShip.onslot_1",
			@"fourthShip.onslot_2",
			@"fourthShip.onslot_3",
			@"fourthShip.onslot_4",
			
			@"fifthShip.onslot_0",
			@"fifthShip.onslot_1",
			@"fifthShip.onslot_2",
			@"fifthShip.onslot_3",
			@"fifthShip.onslot_4",
			
			@"sixthShip.onslot_0",
			@"sixthShip.onslot_1",
			@"sixthShip.onslot_2",
			@"sixthShip.onslot_3",
			@"sixthShip.onslot_4",
			
			@"flagShip.equippedItem",
			@"secondShip.equippedItem",
			@"thirdShip.equippedItem",
			@"fourthShip.equippedItem",
			@"fifthShip.equippedItem",
			@"sixthShip.equippedItem",
			
			nil];
}

- (void)setSelectedFleetNumber:(NSNumber *)fleetNumber
{
	_selectedFleetNumber = fleetNumber;
	[self buildFleet];
}

- (NSNumber *)totalSakuteki
{
	NSInteger total = 0;
	total += [self.flagShip.sakuteki_0 integerValue];
	total += [self.secondShip.sakuteki_0 integerValue];
	total += [self.thirdShip.sakuteki_0 integerValue];
	total += [self.fourthShip.sakuteki_0 integerValue];
	total += [self.fifthShip.sakuteki_0 integerValue];
	total += [self.sixthShip.sakuteki_0 integerValue];
	
	return @(total);
}

- (NSUInteger)seikuAtIndex:(NSUInteger)index
{
	if(index > 5) {
		return 0;
	}
	
	HMKCShipObject *ship = nil;
	NSError *error = nil;
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSString *key = [NSString stringWithFormat:@"ship_%ld", index];
	NSNumber *shipIdNumber = [self.selectedFleet valueForKey:key];
	if(!shipIdNumber) return 0;
	NSInteger shipId = [shipIdNumber integerValue];
	NSArray *array = nil;
	if(shipId != -1) {
		array = [store objectsWithEntityName:@"Ship"
									   error:&error
							 predicateFormat:@"id = %ld", shipId];
	} else {
		return 0;
	}
	if(array.count == 0) {
		NSLog(@"Could not found ship of id %@", shipIdNumber);
	} else {
		ship = array[0];
	}
	if(!ship) return 0;
//	NSLog(@"ship name -> %@ equipped count -> %ld", ship.name, ship.equippedItem.count);
	NSArray *effectiveTypes = @[@6, @7, @8, @11];
	__block NSInteger totalSeiku = 0;
#if 0
	[ship.equippedItem enumerateObjectsUsingBlock:^(HMKCSlotItemObject *slotItem, NSUInteger idx, BOOL *stop) {
		HMKCMasterSlotItemObject *master = slotItem.master_slotItem;
		NSNumber *type2 = master.type_2;
		if(![effectiveTypes containsObject:type2]) {
			NSLog(@"Type %@ is not effective.", type2);
			return;
		}
		
		NSString *key = [NSString stringWithFormat:@"onslot_%ld", idx];
		NSNumber *itemCountValue = [ship valueForKey:key];
		NSNumber *taikuValue = master.tyku;
		NSInteger itemCount = [itemCountValue integerValue];
		NSInteger taiku = [taikuValue integerValue];
		if(itemCount && taiku) {
			totalSeiku += floor(taiku * sqrt(itemCount));
			NSLog(@"slot -> %ld, name -> %@, itemCount -> %ld, taiku -> %ld, total -> %ld", idx, master.name, itemCount, taiku, totalSeiku);
		} else {
			NSLog(@"itemCount -> %ld, taiku -> %ld", itemCount, taiku);
		}
	}];
#else
	for(NSInteger i = 0; i < 5; i++) {
		NSString *key = [NSString stringWithFormat:@"slot_%ld", i];
		NSNumber *itemId = [ship valueForKey:key];
		if(itemId.integerValue == -1) break;
		error = nil;
		array = [store objectsWithEntityName:@"SlotItem"
									   error:&error
							 predicateFormat:@"id = %@", itemId];
		if(array.count == 0) continue;
		HMKCSlotItemObject *slotItem = array[0];
		HMKCMasterSlotItemObject *master = slotItem.master_slotItem;
		NSNumber *type2 = master.type_2;
		if(![effectiveTypes containsObject:type2]) {
//			NSLog(@"Type %@ is not effective.", type2);
			continue;
		}
		
		key = [NSString stringWithFormat:@"onslot_%ld", i];
		NSNumber *itemCountValue = [ship valueForKey:key];
		NSNumber *taikuValue = master.tyku;
		NSInteger itemCount = [itemCountValue integerValue];
		NSInteger taiku = [taikuValue integerValue];
		if(itemCount && taiku) {
			totalSeiku += floor(taiku * sqrt(itemCount));
//			NSLog(@"slot -> %ld, name -> %@, itemCount -> %ld, taiku -> %ld, total -> %ld", i, master.name, itemCount, taiku, totalSeiku);
		} else {
//			NSLog(@"itemCount -> %ld, taiku -> %ld", itemCount, taiku);
		}
	}
#endif
	
	return totalSeiku;
}

- (NSNumber *)totalSeiku
{
	NSUInteger totalSeiku = 0;
	for(NSUInteger i = 0; i < 6; i++) {
		totalSeiku += [self seikuAtIndex:i];
	}
	
	return @(totalSeiku);
}

- (HMKCDeck *)fleetAtIndex:(NSInteger)fleetNumner
{
	NSArray *decks = [self.deckController arrangedObjects];
	if(fleetNumner == 0 || decks.count < fleetNumner) return nil;
	return decks[fleetNumner - 1];
}
- (NSArray *)fleetMemberAtIndex:(NSInteger)fleetNumber
{
	HMKCDeck *deck = [self fleetAtIndex:fleetNumber];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:6];
	
	NSError *error = nil;
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	for(NSInteger i = 0; i < 6; i++) {
		NSString *key = [NSString stringWithFormat:@"ship_%ld", i];
		NSNumber *shipIdNumber = [deck valueForKey:key];
		NSInteger shipId = [shipIdNumber integerValue];
		if(shipId == -1) continue;
		NSArray *array = nil;
		if(shipId != -1) {
			array = [store objectsWithEntityName:@"Ship"
										   error:&error
								 predicateFormat:@"id = %ld", shipId];
		}
		if(array.count == 0) {
			NSLog(@"Could not found ship of id %@", shipIdNumber);
		} else {
			[result addObject:array[0]];
		}
	}
	return result;
}
@end
