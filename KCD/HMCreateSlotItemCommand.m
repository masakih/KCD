//
//  HMCreateSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCreateSlotItemCommand.h"

#import "HMCoreDataManager.h"
#import "HMLocalDataStore.h"
#import "HMKaihatuHistory.h"


@implementation HMCreateSlotItemCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kousyou/createitem"]) return YES;
	
	return NO;
}
- (void)execute
{
	id data = [self.json valueForKey:@"api_data"];
	BOOL created = [[data valueForKey:@"api_create_flag"] boolValue];
	NSString *name = nil;
	NSNumber *numberOfUsedKaihatuSizai = nil;
	
	NSManagedObjectContext *context = [[HMCoreDataManager defaultManager] managedObjectContext];
	
	if(created) {
		NSNumber *slotItemID = [data valueForKey:@"api_slotitem_id"];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterSlotItem"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", slotItemID];
		[req setPredicate:predicate];
		
		NSArray *array = [context executeFetchRequest:req error:NULL];
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
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = 1"];
	[req setPredicate:predicate];
	
	NSArray *array = [context executeFetchRequest:req error:NULL];
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
	
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	NSManagedObjectContext *localStoreContext = [lds managedObjectContext];
	HMKaihatuHistory *newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"KaihatuHistory"
															  inManagedObjectContext:localStoreContext];
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
