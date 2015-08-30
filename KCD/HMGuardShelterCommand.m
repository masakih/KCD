
//
//  HMGuardShelterCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/13.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMGuardShelterCommand.h"

#import "HMTemporaryDataStore.h"
#import "HMServerDataStore.h"

#import "HMKCDeck.h"


NSString *HMGuardShelterCommandDidUpdateGuardExcapeNotification = @"HMGuardShelterCommandDidUpdateGuardExcapeNotification";

@implementation HMGuardShelterCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_combined_battle/goback_port"];
}
- (void)execute
{
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/battleresult"]) {
		[self registerReserve];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]) {
		[self removeAllEntry];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/goback_port"]) {
		[self ensureGuardShelter];
		return;
	}
}


- (NSArray *)fleetMenbersForFleetID:(NSNumber *)feetID
{
	// 艦隊メンバーを取得
	NSError *error = nil;
	HMServerDataStore *serverStore = [HMServerDataStore defaultManager];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", feetID];
	NSArray *decks = [serverStore objectsWithEntityName:@"Deck"
											  predicate:predicate
												  error:&error];
	if(error) {
		[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		return nil;
	}
	
	if(decks.count == 0) {
		[self log:@"Deck is invalid. %s", __PRETTY_FUNCTION__];
		return nil;
	}
	HMKCDeck *deck = decks[0];
	NSArray *shipIds = @[
						 deck.ship_0,
						 deck.ship_1,
						 deck.ship_2,
						 deck.ship_3,
						 deck.ship_4,
						 deck.ship_5,
						 ];
	
	return shipIds;
}
- (void)registerReserve
{
	id data = [self.json objectForKey:@"api_data"];
	id escape = [data objectForKey:@"api_escape"];
	if(!escape || [escape isEqual:[NSNull null]]) return;
	
	NSArray *guardians = [escape objectForKey:@"api_tow_idx"];
	if([guardians isEqual:[NSNull null]] || guardians.count == 0) return;
	NSNumber *guardianPosition = guardians[0];
	NSArray *secondFleet = [self fleetMenbersForFleetID:@2];
	if(!secondFleet) return;
	NSNumber *guardianID = secondFleet[guardianPosition.integerValue - 6 - 1];
	
	
	NSNumber  *damagedShipPosition = [escape objectForKey:@"api_escape_idx"];
	if([damagedShipPosition isKindOfClass:[NSArray class]]) {
		damagedShipPosition = [(NSArray *)damagedShipPosition objectAtIndex:0];
	}
	NSNumber *damagedShipID = nil;
	if(damagedShipPosition.integerValue > 6) {
		damagedShipID = secondFleet[damagedShipPosition.integerValue - 6 - 1];
	} else {
		NSArray *firstFleet = [self fleetMenbersForFleetID:@1];
		damagedShipID = firstFleet[damagedShipPosition.integerValue - 1];
	}
	
	
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"GuardEscaped"
														   inManagedObjectContext:store.managedObjectContext];
	[object setValue:guardianID forKey:@"shipID"];
	[object setValue:@NO forKey:@"ensured"];
	
	object = [NSEntityDescription insertNewObjectForEntityForName:@"GuardEscaped"
										   inManagedObjectContext:store.managedObjectContext];
	[object setValue:damagedShipID forKey:@"shipID"];
	[object setValue:@NO forKey:@"ensured"];
	
}

- (void)removeAllEntry
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"GuardEscaped"
											error:&error
								  predicateFormat:nil];
	if(error) {
		NSLog(@"GuardEscaped is invalid. -> %@", error);
		return;
	}
	if(!array) {
		NSLog(@"GuardEscaped is invalid. -> %@", error);
		return;
	}
	for(NSManagedObject *object in array) {
		[store.managedObjectContext deleteObject:object];
	}
	[store saveAction:nil];
	[NSThread sleepForTimeInterval:0.1];
	
	[self notify];
}
- (void)ensureGuardShelter
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSError *error = nil;
	NSArray *shelters = [store objectsWithEntityName:@"GuardEscaped"
											   error:&error
									 predicateFormat:nil];
	if(error) {
		NSLog(@"GuardEscaped is invalid. -> %@", error);
		return;
	}
	if(!shelters) {
		NSLog(@"GuardEscaped is invalid. -> %@", error);
		return;
	}
	for(NSManagedObject *object in shelters) {
		[object setValue:@YES forKey:@"ensured"];
	}
	[store saveAction:nil];
	[NSThread sleepForTimeInterval:0.1];
	
	[self notify];
}

- (void)notify
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:HMGuardShelterCommandDidUpdateGuardExcapeNotification
					  object:self
					userInfo:nil];
}

@end
