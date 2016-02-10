//
//  HMApplySuppliesCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMApplySuppliesCommand.h"

#import "HMKCShipObject+Extensions.h"
#import "HMServerDataStore.h"


@implementation HMApplySuppliesCommand
- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	
	NSDictionary *data = self.json[@"api_data"];
	NSArray *shipInfos = data[@"api_ship"];
	
	for(NSDictionary *updataInfo in shipInfos) {
		NSError *error = nil;
		NSArray<HMKCShipObject *> *ships = [store objectsWithEntityName:@"Ship"
																  error:&error
														predicateFormat:@"id = %@", @([updataInfo[@"api_id"] integerValue])];
		if(ships.count == 0) {
			if(error) {
				NSLog(@"Error: at %@ : %@", NSStringFromClass([self class]), error);
			}
			continue;
		}
		
		ships[0].bull = updataInfo[@"api_bull"];
		ships[0].fuel = updataInfo[@"api_fuel"];
		NSArray *onslots = updataInfo[@"api_onslot"];
		ships[0].onslot_0 = onslots[0];
		ships[0].onslot_1 = onslots[1];
		ships[0].onslot_2 = onslots[2];
		ships[0].onslot_3 = onslots[3];
		ships[0].onslot_4 = onslots[4];
	}
}
@end
