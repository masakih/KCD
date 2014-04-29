//
//  HMMaserShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMaserShipCommand.h"


@implementation HMMaserShipCommand
- (NSString *)dataKey
{
	return @"api_data.api_mst_ship";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterShip"];
}

- (void)setStype:(id)value toObject:(NSManagedObject *)object
{
	id currentValue = [object valueForKeyPath:@"stype.name"];
	if(currentValue && ![currentValue isEqual:[NSNull null]]) return;
	
	NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
	
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterSType"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", value];
	[req setPredicate:predicate];
	NSError *error = nil;
	id result = [managedObjectContext executeFetchRequest:req
													error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(!result || [result count] == 0) {
		[self log:@"Could not find stype of id (%@)", value];
		return;
	}
	
	[object setValue:result[0] forKey:@"api_stype"];
}
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	if([key isEqualToString:@"api_stype"]) {
		[self setStype:value toObject:object];
		return YES;
	}
	return NO;
}

@end
