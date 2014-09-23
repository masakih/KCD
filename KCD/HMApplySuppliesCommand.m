//
//  HMApplySuppliesCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMApplySuppliesCommand.h"

#import "HMServerDataStore.h"


@implementation HMApplySuppliesCommand
- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	
	NSDictionary *data = self.json[@"api_data"];
	NSArray *shipInfos = data[@"api_ship"];
	
	for(NSDictionary *updataInfo in shipInfos) {
		NSError *error = nil;
		NSArray *array = [store objectsWithEntityName:@"Ship"
												error:&error
									  predicateFormat:@"id = %@", @([updataInfo[@"api_id"] integerValue])];
		if(array.count == 0) {
			if(error) {
				NSLog(@"Error: at %@ : %@", NSStringFromClass([self class]), error);
			}
			continue;
		}
		
		id ship = array[0];
		[ship setValue:updataInfo[@"api_bull"] forKey:@"bull"];
		[ship setValue:updataInfo[@"api_fuel"] forKey:@"fuel"];
	}
}
@end
