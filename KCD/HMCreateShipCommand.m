//
//  HMCreateShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCreateShipCommand.h"

#import "HMServerDataStore.h"
#import "HMLocalDataStore.h"
#import "HMKenzoMark.h"
#import "HMKCKenzoDock.h"
#import "HMKCDeck+Extension.h"
#import "HMKCMasterShipObject.h"
#import "HMKCShipObject+Extensions.h"
#import "HMKCBasic.h"


/**
 *  建造履歴に残すために秘書艦と司令部レベルを保存する
 */
@implementation HMCreateShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kousyou/createship"]) return YES;
	
	return NO;
}
- (void)execute
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
		NSArray<HMKCKenzoDock *> *kenzoDocks = [serverDataStore objectsWithEntityName:@"KenzoDock"
																				error:NULL
																	  predicateFormat:@"id = %@", @([[self.arguments valueForKey:@"api_kdock_id"] integerValue])];
		if([kenzoDocks count] == 0) {
			NSLog(@"KenzoDock data is invalid.");
			return;
		}
		
		HMKCKenzoDock *kdock = kenzoDocks[0];
		NSNumber *item1 = kdock.item1;
		
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
		
		//
		HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
		HMKenzoMark *newObejct = nil;
		NSArray<HMKenzoMark *> *kenzomarks = [lds objectsWithEntityName:@"KenzoMark"
																  error:NULL
														predicateFormat:@"kDockId = %@", @([[self.arguments valueForKey:@"api_kdock_id"] integerValue])];
		if([kenzomarks count] == 0) {
			newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"KenzoMark"
													  inManagedObjectContext:[lds managedObjectContext]];
		} else {
			newObejct = kenzomarks[0];
		}
		
		newObejct.fuel = item1;
		newObejct.bull = kdock.item2;
		newObejct.steel = kdock.item3;
		newObejct.bauxite = kdock.item4;
		newObejct.kaihatusizai = kdock.item5;
		newObejct.created_ship_id = kdock.created_ship_id;
		newObejct.flagShipLv = flagShipLv;
		newObejct.flagShipName = flagShipName;
		newObejct.commanderLv = basic.level;
		newObejct.kDockId = @([[self.arguments valueForKey:@"api_kdock_id"] integerValue]);
	});
}
@end
