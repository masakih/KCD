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
#import "HMKCMasterSlotItemObject.h"
#import "HMKCDeck+Extension.h"
#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterShipObject.h"
#import "HMKCBasic.h"

@implementation HMStoreCreateSlotItemHistoryCommand

- (void)execute
{
	id data = [self.json valueForKey:@"api_data"];
	BOOL created = [[data valueForKey:@"api_create_flag"] boolValue];
	NSString *name = nil;
	NSNumber *numberOfUsedKaihatuSizai = nil;
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	
	if(created) {
		NSNumber *slotItemID = [data valueForKeyPath:@"api_slot_item.api_slotitem_id"];
		NSArray<HMKCMasterSlotItemObject *> *masterSlotItems = [serverDataStore objectsWithEntityName:@"MasterSlotItem"
																								error:NULL
																					  predicateFormat:@"id = %@", slotItemID];
		if([masterSlotItems count] == 0) {
			NSLog(@"MasterSlotItem data is invalid or api_slotitem_id is invalid.");
			return;
		}
		name = masterSlotItems[0].name;
		numberOfUsedKaihatuSizai = @1;
	} else {
		name = NSLocalizedString(@"fail to develop", @"");
		numberOfUsedKaihatuSizai = @0;
	}
	
	// Deck -> FlagShip
	NSArray<HMKCDeck *> *decks = [serverDataStore objectsWithEntityName:@"Deck" error:NULL predicateFormat:@"id = 1"];
	if([decks count] == 0) {
		NSLog(@"Deck data is invalid.");
		return;
	}
	HMKCDeck *deck = decks[0];
	NSNumber *flagShipID = deck.ship_0;
	NSArray<HMKCShipObject *> *ships = [serverDataStore objectsWithEntityName:@"Ship" error:NULL predicateFormat:@"id = %@", flagShipID];
	if([ships count] == 0) {
		NSLog(@"Ship data is invalid or ship_0 is invalid.");
		return;
	}
	HMKCShipObject *flagShip = ships[0];
	NSNumber *flagShipLv = flagShip.lv;
	NSString *flagShipName = flagShip.master_ship.name;
	
	// Basic -> level
	NSArray<HMKCBasic *> *basics = [serverDataStore objectsWithEntityName:@"Basic" predicate:nil error:NULL];
	if([basics count] == 0) {
		NSLog(@"Basic data is invalid.");
		return;
	}
	HMKCBasic *basic = basics[0];
	
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
	newObejct.commanderLv = basic.level;
	newObejct.date = [NSDate dateWithTimeIntervalSinceNow:0];
	
	[lds saveAction:nil];
}

@end
