//
//  HMStoreCreateSlotItemHistoryCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMStoreCreateSlotItemHistoryCommand.h"

#import "HMServerDataStore.h"
#import "HMLocalDataStore.h"
#import "HMKaihatuHistory.h"

@implementation HMStoreCreateSlotItemHistoryCommand

- (void)execute
{
	id data = [self.json valueForKey:@"api_data"];
	BOOL created = [[data valueForKey:@"api_create_flag"] boolValue];
	NSString *name = nil;
	NSNumber *numberOfUsedKaihatuSizai = nil;
	
	HMServerDataStore *serverDataStore = [HMServerDataStore defaultManager];
	
	if(created) {
		NSNumber *slotItemID = [data valueForKeyPath:@"api_slot_item.api_slotitem_id"];
		NSArray *array = [serverDataStore objectsWithEntityName:@"MasterSlotItem"
														  error:NULL
												predicateFormat:@"id = %@", slotItemID];
		if([array count] == 0) {
			NSLog(@"MasterSlotItem data is invalid or api_slotitem_id is invalid.");
			return;
		}
		name = [array[0] valueForKey:@"name"];
		numberOfUsedKaihatuSizai = @1;
	} else {
		name = NSLocalizedString(@"fail to develop", @"");
		numberOfUsedKaihatuSizai = @0;
	}
	
	// Deck -> FlagShip
	NSArray *array = [serverDataStore objectsWithEntityName:@"Deck" error:NULL predicateFormat:@"id = 1"];
	if([array count] == 0) {
		NSLog(@"Deck data is invalid.");
		return;
	}
	id deck = array[0];
	id flagShipID = [deck valueForKey:@"ship_0"];
	array = [serverDataStore objectsWithEntityName:@"Ship" error:NULL predicateFormat:@"id = %@", flagShipID];
	if([array count] == 0) {
		NSLog(@"Ship data is invalid or ship_0 is invalid.");
		return;
	}
	id flagShip = array[0];
	NSNumber *flagShipLv = [flagShip valueForKey:@"lv"];
	NSString *flagShipName = [flagShip valueForKeyPath:@"master_ship.name"];
	
	// Basic -> level
	array = [serverDataStore objectsWithEntityName:@"Basic" predicate:nil error:NULL];
	if([array count] == 0) {
		NSLog(@"Basic data is invalid.");
		return;
	}
	id basic = array[0];
	
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	HMKaihatuHistory *newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"KaihatuHistory"
																inManagedObjectContext:[lds managedObjectContext]];
	newObejct.name = name;
	newObejct.fuel = @([[self.arguments valueForKey:@"api_item1"] integerValue]);
	newObejct.bull = @([[self.arguments valueForKey:@"api_item2"] integerValue]);
	newObejct.steel = @([[self.arguments valueForKey:@"api_item3"] integerValue]);
	newObejct.bauxite = @([[self.arguments valueForKey:@"api_item4"] integerValue]);
	newObejct.kaihatusizai = numberOfUsedKaihatuSizai;
	newObejct.flagShipLv = flagShipLv;
	newObejct.flagShipName = flagShipName;
	newObejct.commanderLv = [basic valueForKey:@"level"];
	newObejct.date = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
