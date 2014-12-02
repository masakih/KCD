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

@interface HMFleetInformation ()
@property (strong) NSArray *shipNameKeys;

@property (strong) NSArrayController *deckController;

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
@synthesize fleetNumber = _fleetNumber;

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
	id deck = [self.deckController valueForKeyPath:@"selection.self"];
	NSString *key = [NSString stringWithFormat:@"ship_%ld", shipNumber];
	NSNumber *shipIdNumber = [deck valueForKey:key];
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
	
	NSInteger fleetId = [self.fleetNumber integerValue];
	if(fleetId > 6 || fleetId < 0) {
		return;
	}
	
	id deck = [self.deckController valueForKeyPath:@"selection.self"];
	self.name = [deck valueForKey:@"name"];
	
	for(NSInteger i = 0; i < 6; i++) {
		[self changeShipWithNumber:i];
	}
}

+ (NSSet *)keyPathsForValuesAffectingName
{
	return [NSSet setWithObject:@"deckController.selection"];
}

+ (NSSet *)keyPathsForValuesAffectingTotalSakuteki
{
	return [NSSet setWithObjects:@"deckController.selection",
			@"flagShip", @"secondShip", @"thirdShip", @"fourthShip", @"fifthShip", @"sixthShip",
			nil];
}

- (NSNumber *)fleetNumber
{
	return _fleetNumber;
}
- (void)setFleetNumber:(NSNumber *)fleetNumber
{
	_fleetNumber = fleetNumber;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", [fleetNumber integerValue]];
	[self.deckController setFetchPredicate:predicate];
	
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

@end
