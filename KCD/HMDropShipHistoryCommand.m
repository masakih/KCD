//
//  HMDropShipHistoryCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/02/18.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMDropShipHistoryCommand.h"

#import "HMServerDataStore.h"
#import "HMLocalDataStore.h"
#import "HMTemporaryDataStore.h"
#import "HMDropShipHistory.h"

@implementation HMDropShipHistoryCommand

- (NSManagedObject *)battle
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore defaultManager];
	NSError *error = nil;
	NSArray *array  = [store objectsWithEntityName:@"Battle" predicate:nil error:&error];
	if(error) {
		NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
	}
	return array.count > 0 ? array[0] : nil;
}
- (void)execute
{
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]
	   || [self.api isEqualToString:@"/kcsapi/api_get_member/ship2"]) {
		[self storeToVisible];
	}
	if(![self.api hasSuffix:@"battleresult"]) return;
	
	id data = [self.json valueForKey:@"api_data"];
	id getShip = [data valueForKey:@"api_get_ship"];
	if(!getShip || [getShip isKindOfClass:[NSNull class]]) return;
	
	id battle = [self battle];
	if(!battle) {
		NSLog(@"Can not get battle object");
		return;
	}
	
	id mapAreaId = [battle valueForKey:@"mapArea"];
	id mapInfoId = [battle valueForKey:@"mapInfo"];
	id mapCellNo = [battle valueForKey:@"no"];
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"MasterMapInfo"
											error:&error
								  predicateFormat:@"maparea_id = %@ AND %K = %@", mapAreaId, @"no", mapInfoId];
	if(error) {
		NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
	}
	if(array.count == 0) {
		NSLog(@"%s error: Can not get mapInfo", __PRETTY_FUNCTION__);
		return;
	}
	id mapInfoName = [array[0] valueForKey:@"name"];
	
	error = nil;
	array = [store objectsWithEntityName:@"MasterMapArea"
								   error:&error
						 predicateFormat:@"id = %@", mapAreaId];
	if(error) {
		NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
	}
	if(array.count == 0) {
		NSLog(@"%s error: Can not get mapArea", __PRETTY_FUNCTION__);
		return;
	}
	id mapAreaName = [array[0] valueForKey:@"name"];
	
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	HMDropShipHistory *newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"HiddenDropShipHistory"
																inManagedObjectContext:[lds managedObjectContext]];
	
	newObejct.shipName = [getShip valueForKey:@"api_ship_name"];
	newObejct.mapArea = [NSString stringWithFormat:@"%@", mapAreaId];
	newObejct.mapAreaName = mapAreaName;
	newObejct.mapInfo = mapInfoId;
	newObejct.mapInfoName = mapInfoName;
	newObejct.mapCell = mapCellNo;
	newObejct.winRank = [data valueForKey:@"api_win_rank"];
	newObejct.date = [NSDate dateWithTimeIntervalSinceNow:0];
	
	[lds saveAction:nil];
}

- (void)storeToVisible
{
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	NSError *error = nil;
	NSArray *array = [lds objectsWithEntityName:@"HiddenDropShipHistory"
									  predicate:nil
										  error:&error];
	if(error) {
		NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
	}
	NSManagedObjectContext *context = lds.managedObjectContext;
	for(HMDropShipHistory *history in array) {
		HMDropShipHistory *newObejct = [NSEntityDescription insertNewObjectForEntityForName:@"DropShipHistory"
																	 inManagedObjectContext:[lds managedObjectContext]];
		
		newObejct.shipName = history.shipName;
		newObejct.mapArea = history.mapArea;
		newObejct.mapAreaName = history.mapAreaName;
		newObejct.mapInfo = history.mapInfo;
		newObejct.mapInfoName = history.mapInfoName;
		newObejct.mapCell = history.mapCell;
		newObejct.winRank = history.winRank;
		newObejct.date = history.date;
		
		[context deleteObject:history];
	}
	
	[lds saveAction:nil];
}
@end
