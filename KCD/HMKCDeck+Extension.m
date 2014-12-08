//
//  HMKCDeck+Extension.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/05.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCDeck+Extension.h"

@implementation HMKCDeck (Extension)

- (HMKCShipObject *)shipOfShipNumber:(NSInteger)shipNumber
{
	id ship = nil;
	NSError *error = nil;
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSString *key = [NSString stringWithFormat:@"ship_%ld", shipNumber];
	[self willAccessValueForKey:key];
	NSNumber *shipIdNumber = [self valueForKey:key];
	[self didAccessValueForKey:key];
	NSInteger shipId = [shipIdNumber integerValue];
	NSArray *array = nil;
	if(shipId != -1) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", shipId];
		[request setPredicate:predicate];
		array = [moc executeFetchRequest:request error:&error];
	}
	if(shipId != -1 && array.count == 0) {
		NSLog(@"Could not found ship of id %@", shipIdNumber);
	} else {
		ship = array[0];
	}
	
	return ship;
}
- (HMKCShipObject *)flagShip
{
	return [self shipOfShipNumber:0];
}
- (HMKCShipObject *)secondShip
{
	return [self shipOfShipNumber:1];
}
- (HMKCShipObject *)thirdShip
{
	return [self shipOfShipNumber:2];
}
- (HMKCShipObject *)fourthShip
{
	return [self shipOfShipNumber:3];
}
- (HMKCShipObject *)fifthShip
{
	return [self shipOfShipNumber:4];
}
- (HMKCShipObject *)sixthShip
{
	return [self shipOfShipNumber:5];
}

	

@end
