//
//  HMPowerUpCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPowerUpCommand.h"

#import "HMServerDataStore.h"

@implementation HMPowerUpCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kaisou/powerup"]) return YES;
	return NO;
}
- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSString *usedShipsStrings = [self.arguments objectForKey:@"api_id_items"];
	NSArray *usedShipStringArray = [usedShipsStrings componentsSeparatedByString:@","];
	
	for(NSString *shipId in usedShipStringArray) {
		NSError *error = nil;
		NSArray *ships = [store objectsWithEntityName:@"Ship"
												error:&error
									  predicateFormat:@"id = %@", @([shipId integerValue])];
		if(ships.count == 0) {
			continue;
		}
		[moc deleteObject:ships[0]];
	}
}

@end
