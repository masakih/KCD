//
//  HMKenzoMarkCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKenzoMarkCommand.h"

#import "HMServerDataStore.h"
#import "HMLocalDataStore.h"
#import "HMKenzoHistory.h"
#import "HMKenzoMark.h"
#import "HMKCKenzoDock.h"
#import "HMKCMasterShipObject.h"
#import "HMKCMasterSType.h"


/**
 *  建造履歴を残す
 */
@implementation HMKenzoMarkCommand
- (void)execute
{
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSArray<HMKCKenzoDock *> *kenzoDocks = [serverDataStore objectsWithEntityName:@"KenzoDock"
																	   error:NULL
															 predicateFormat:@"id = %@", @([[self.arguments valueForKey:@"api_kdock_id"] integerValue])];
	if([kenzoDocks count] == 0) {
		NSLog(@"KenzoDock data is invalid.");
		return;
	}
	NSNumber *item1 = kenzoDocks[0].item1;
	
	//
	NSArray<HMKCMasterShipObject *> *ships = [serverDataStore objectsWithEntityName:@"MasterShip"
																			  error:NULL
															  predicateFormat:@"id = %@", kenzoDocks[0].created_ship_id];
	if([ships count] == 0) {
		NSLog(@"MasterShip data is invalid or ship_id is invalid.");
		return;
	}
	
	//
	NSNumber *flagShipLv = nil;
	NSString *flafShipName = nil;
	NSNumber *commanderLv = nil;
	HMLocalDataStore *localDataStore = [HMLocalDataStore oneTimeEditor];
	NSArray<HMKenzoMark *> *kenzoMarks = [localDataStore objectsWithEntityName:@"KenzoMark"
																		 error:NULL
															   predicateFormat:
										  @"fuel = %@ AND bull = %@ AND steel = %@ AND bauxite = %@ AND kaihatusizai = %@ AND kDockId = %@ AND created_ship_id = %@",
										  item1, kenzoDocks[0].item2, kenzoDocks[0].item3, kenzoDocks[0].item4, kenzoDocks[0].item5,
										  @([[self.arguments valueForKey:@"api_kdock_id"] integerValue]), kenzoDocks[0].created_ship_id
										  ];
	if([kenzoMarks count] != 0) {
		flagShipLv = kenzoMarks[0].flagShipLv;
		flafShipName = kenzoMarks[0].flagShipName;
		commanderLv = kenzoMarks[0].commanderLv;
	}
	
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	NSManagedObjectContext *localStoreContext = [lds managedObjectContext];
	HMKenzoHistory *newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"KenzoHistory"
															  inManagedObjectContext:localStoreContext];
	newObejct.name = ships[0].name;
	newObejct.sTypeId = ships[0].stype.id;
	newObejct.fuel = item1;
	newObejct.bull = kenzoDocks[0].item2;
	newObejct.steel = kenzoDocks[0].item3;
	newObejct.bauxite = kenzoDocks[0].item4;
	newObejct.kaihatusizai = kenzoDocks[0].item5;
	newObejct.flagShipLv = flagShipLv;
	newObejct.flagShipName = flafShipName;
	newObejct.commanderLv = commanderLv;
	newObejct.date = [NSDate dateWithTimeIntervalSinceNow:0];
	
	[lds saveAction:nil];
}
@end
