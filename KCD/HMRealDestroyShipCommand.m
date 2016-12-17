//
//  HMRealDestroyShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/07/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMRealDestroyShipCommand.h"

#import "HMServerDataStore.h"

@implementation HMRealDestroyShipCommand
- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	
	NSString *destroyedShipId = [self.arguments objectForKey:@"api_ship_id"];
	
	NSError *error = nil;
	NSArray<NSManagedObject *> *ships = [store objectsWithEntityName:@"Ship"
															   error:&error
													 predicateFormat:@"id = %@", @([destroyedShipId integerValue])];
	if(ships.count == 0) {
		return;
	}
	[store deleteObject:ships[0]];
}
@end
