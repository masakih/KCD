//
//  HMCreateShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCreateShipCommand.h"

#import "HMCoreDataManager.h"
#import "HMLocalDataStore.h"
#import "HMKenzoMark.h"

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
		NSManagedObjectContext *context = [[HMCoreDataManager defaultManager] managedObjectContext];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"KenzoDock"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", [self.arguments valueForKey:@"api_kdock_id"]];
		[req setPredicate:predicate];
		
		NSArray *array = [context executeFetchRequest:req error:NULL];
		if([array count] == 0) {
			NSLog(@"KenzoDock data is invalid.");
			return;
		}
		
		id kdock = array[0];
		NSNumber *item1 = [kdock valueForKey:@"item1"];
		
		// Deck -> FlagShip
		req = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
		predicate = [NSPredicate predicateWithFormat:@"id = 1"];
		[req setPredicate:predicate];
		
		array = [context executeFetchRequest:req error:NULL];
		if([array count] == 0) {
			NSLog(@"Deck data is invalid.");
			return;
		}
		id deck = array[0];
		id flagShipID = [deck valueForKey:@"ship_0"];
		req = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
		predicate = [NSPredicate predicateWithFormat:@"id = %@", flagShipID];
		[req setPredicate:predicate];
		array = [context executeFetchRequest:req error:NULL];
		if([array count] == 0) {
			NSLog(@"Ship data is invalid or ship_0 is invalid.");
			return;
		}
		id flagShip = array[0];
		NSNumber *flagShipLv = [flagShip valueForKey:@"lv"];
		NSString *flagShipName = [flagShip valueForKeyPath:@"master_ship.name"];
		
		// Basic -> level
		req = [NSFetchRequest fetchRequestWithEntityName:@"Basic"];
		
		array = [context executeFetchRequest:req error:NULL];
		if([array count] == 0) {
			NSLog(@"Basic data is invalid.");
			return;
		}
		id basic = array[0];
		
		//
		HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
		NSManagedObjectContext *localStoreContext = [lds managedObjectContext];
		HMKenzoMark *newObejct = nil;
		req = [NSFetchRequest fetchRequestWithEntityName:@"KenzoMark"];
		predicate = [NSPredicate predicateWithFormat:@"kDockId = %@", @([[self.arguments valueForKey:@"api_kdock_id"] integerValue])];
		[req setPredicate:predicate];
		array = [localStoreContext executeFetchRequest:req error:NULL];
		if([array count] == 0) {
			newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"KenzoMark"
													  inManagedObjectContext:localStoreContext];
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
