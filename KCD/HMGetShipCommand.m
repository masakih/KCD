//
//  HMGetShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMGetShipCommand.h"

#import "HMServerDataStore.h"
#import "HMLocalDataStore.h"
#import "HMKenzoHistory.h"


@implementation HMGetShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kousyou/getship"]) return YES;
	
	return NO;
}
- (void)execute
{
	NSManagedObjectContext *context = [[HMServerDataStore defaultManager] managedObjectContext];
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
	
	//
	req = [NSFetchRequest fetchRequestWithEntityName:@"MasterShip"];
	predicate = [NSPredicate predicateWithFormat:@"id = %@", [kdock valueForKey:@"created_ship_id"]];
	[req setPredicate:predicate];
	
	array = [context executeFetchRequest:req error:NULL];
	if([array count] == 0) {
		NSLog(@"MasterShip data is invalid or ship_id is invalid.");
		return;
	}
	id ship = array[0];
	
	//
	NSNumber *flagShipLv = nil;
	NSString *flafShipName = nil;
	NSNumber *commanderLv = nil;
	context = [[HMLocalDataStore defaultManager] managedObjectContext];
	req = [NSFetchRequest fetchRequestWithEntityName:@"KenzoMark"];
	predicate = [NSPredicate predicateWithFormat:@"fuel = %@ AND bull = %@ AND steel = %@ AND bauxite = %@ AND kaihatusizai = %@ AND kDockId = %@ AND created_ship_id = %@",
				 item1, [kdock valueForKey:@"item2"], [kdock valueForKey:@"item3"], [kdock valueForKey:@"item4"], [kdock valueForKey:@"item5"],
				 @([[self.arguments valueForKey:@"api_kdock_id"] integerValue]), [kdock valueForKey:@"created_ship_id"]
				 ];
	[req setPredicate:predicate];
	
	array = [context executeFetchRequest:req error:NULL];
	if([array count] != 0) {
		flagShipLv = [array[0] valueForKey:@"flagShipLv"];
		flafShipName = [array[0] valueForKey:@"flagShipName"];
		commanderLv = [array[0] valueForKey:@"commanderLv"];
	}
	
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	NSManagedObjectContext *localStoreContext = [lds managedObjectContext];
	HMKenzoHistory *newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"KenzoHistory"
															  inManagedObjectContext:localStoreContext];
	newObejct.name = [ship valueForKey:@"name"];
	newObejct.sTypeId = [ship valueForKeyPath:@"stype.id"];
	newObejct.fuel = item1;
	newObejct.bull = [kdock valueForKey:@"item2"];
	newObejct.steel = [kdock valueForKey:@"item3"];
	newObejct.bauxite = [kdock valueForKey:@"item4"];
	newObejct.kaihatusizai = [kdock valueForKey:@"item5"];
	newObejct.flagShipLv = flagShipLv;
	newObejct.flagShipName = flafShipName;
	newObejct.commanderLv = commanderLv;
	newObejct.date = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
