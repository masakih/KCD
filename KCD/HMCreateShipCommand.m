//
//  HMCreateShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCreateShipCommand.h"

#import "KCD-Swift.h"


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
		NSArray *array = [serverDataStore objectsWithEntityName:@"KenzoDock"
												sortDescriptors:nil
													  predicate:[NSPredicate predicateWithFormat:@"id = %@", @([[self.arguments valueForKey:@"api_kdock_id"] integerValue])]
														  error:NULL];
		if([array count] == 0) {
			NSLog(@"KenzoDock data is invalid.");
			return;
		}
		
		id kdock = array[0];
		NSNumber *item1 = [kdock valueForKey:@"item1"];
		
		// Deck -> FlagShip
		array = [serverDataStore objectsWithEntityName:@"Deck"
									   sortDescriptors:nil
											 predicate:[NSPredicate predicateWithFormat:@"id = 1"]
												 error:NULL];
		if([array count] == 0) {
			NSLog(@"Deck data is invalid.");
			return;
		}
		id deck = array[0];
		id flagShipID = [deck valueForKey:@"ship_0"];
		array = [serverDataStore objectsWithEntityName:@"Ship"
									   sortDescriptors:nil
										predicate:[NSPredicate predicateWithFormat:@"id = %@", flagShipID]
												 error:NULL];
		if([array count] == 0) {
			NSLog(@"Ship data is invalid or ship_0 is invalid.");
			return;
		}
		id flagShip = array[0];
		NSNumber *flagShipLv = [flagShip valueForKey:@"lv"];
		NSString *flagShipName = [flagShip valueForKeyPath:@"master_ship.name"];
		
		// Basic -> level
		array = [serverDataStore objectsWithEntityName:@"Basic"
									   sortDescriptors:nil
											 predicate:nil
												 error:NULL];
		if([array count] == 0) {
			NSLog(@"Basic data is invalid.");
			return;
		}
		id basic = array[0];
		
		//
		HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
		HMKenzoMark *newObejct = nil;
		array = [lds objectsWithEntityName:@"KenzoMark"
						   sortDescriptors:nil
								 predicate:[NSPredicate predicateWithFormat:@"kDockId = %@", @([[self.arguments valueForKey:@"api_kdock_id"] integerValue])]
									 error:NULL];
		if([array count] == 0) {
			newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"KenzoMark"
													  inManagedObjectContext:[lds managedObjectContext]];
		} else {
			newObejct = array[0];
		}
		
		newObejct.fuel = item1;
		newObejct.bull = [kdock valueForKey:@"item2"];
		newObejct.steel = [kdock valueForKey:@"item3"];
		newObejct.bauxite = [kdock valueForKey:@"item4"];
		newObejct.kaihatusizai = [kdock valueForKey:@"item5"];
		newObejct.created_ship_id = [kdock valueForKey:@"created_ship_id"];
		newObejct.flagShipLv = flagShipLv;
		newObejct.flagShipName = flagShipName;
		newObejct.commanderLv = [basic  valueForKey:@"level"];
		newObejct.kDockId = @([[self.arguments valueForKey:@"api_kdock_id"] integerValue]);
	});
}
@end
