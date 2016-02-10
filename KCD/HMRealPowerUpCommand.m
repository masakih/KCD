//
//  HMRealPowerUpCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/12/21.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMRealPowerUpCommand.h"

#import "HMServerDataStore.h"
#import "HMKCShipObject+Extensions.h"


@implementation HMRealPowerUpCommand
- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSString *usedShipsStrings = [self.arguments objectForKey:@"api_id_items"];
	NSArray *usedShipStringArray = [usedShipsStrings componentsSeparatedByString:@","];
	
	for(NSString *shipId in usedShipStringArray) {
		NSError *error = nil;
		NSArray<HMKCShipObject *> *ships = [store objectsWithEntityName:@"Ship"
																  error:&error
														predicateFormat:@"id = %@", @([shipId integerValue])];
		if(ships.count == 0) {
			continue;
		}
		[moc deleteObject:ships[0]];
	}
}
@end
