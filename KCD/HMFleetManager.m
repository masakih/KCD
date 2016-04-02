//
//  HMFleetManager.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/14.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMFleetManager.h"

#import "HMFleet.h"

#import "HMServerDataStore.h"
#import "HMKCShipObject+Extensions.h"


//static HMFleetManager *sharedInstance = nil;

@interface HMFleetManager ()
@property (nonatomic, strong) NSArray<HMFleet *> *fleets;
@property (strong) NSArrayController *fleetController;

@end

@implementation HMFleetManager

- (instancetype)init
{
	self = [super init];
	if(self) {
		[self setupFleets];
	}
	
	return self;
}

- (void)setupFleets
{
	NSMutableArray<HMFleet *> *array = [NSMutableArray array];
	for(NSInteger i = 1; i <= 4; i++) {
		HMFleet *fleet = [HMFleet fleetWithNumber:@(i)];
		[array addObject:fleet];
	}
	_fleets = array;
	
	if(_fleets[0].ships.count == 0) {
		return;
	}
	
	_fleetController = [[NSArrayController alloc] initWithContent:_fleets];
	[_fleetController addObserver:self forKeyPath:@"arrangedObjects.ships" options:0 context:NULL];
}

- (NSArray<HMFleet *> *)fleets
{
	if(_fleets[0].ships.count == 0) {
		[self setupFleets];
	}
	return _fleets;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:@"arrangedObjects.ships"]) {
		[self setNewFleetNumberToShip];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setNewFleetNumberToShip
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	
	// reset fleet
	NSError *error = nil;
	NSArray<HMKCShipObject *> *array = [store objectsWithEntityName:@"Ship"
															  error:&error
													predicateFormat:@"NOT fleet = 0"];
	for(HMKCShipObject *ship in array) {
		ship.fleet = @0;
	}
	
	[self.fleets enumerateObjectsUsingBlock:^(HMFleet * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		for(HMKCShipObject *ship in obj.ships) {
			NSNumber *shipID = ship.id;
			NSError *error = nil;
			NSArray<HMKCShipObject *> *array = [store objectsWithEntityName:@"Ship"
																	  error:&error
															predicateFormat:@"id = %ld", shipID.integerValue];
			if(array.count == 0) continue;
			array[0].fleet = @(idx + 1);
		}
	}];
}

@end
