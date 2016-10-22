//
//  HMMaserShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMaserShipCommand.h"

@interface HMMaserShipCommand ()
@property (nonatomic, copy) NSArray *masterSTypes;
@end

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
	if(currentValue && ![currentValue isEqual:[NSNull null]]
	   && [currentValue isEqual:value]) return;
	
	if(!self.masterSTypes) {
		NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterSType"];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
		[req setSortDescriptors:@[sortDescriptor]];
		NSError *error = nil;
		self.masterSTypes = [managedObjectContext executeFetchRequest:req
															   error:&error];
		if(error) {
			[self log:@"Fetch error: %@", error];
			return;
		}
		if(!self.masterSTypes || [self.masterSTypes count] == 0) {
			[self log:@"Master SType is invalidate"];
			return;
		}
	}
	
	NSRange range = NSMakeRange(0, self.masterSTypes.count);
	NSUInteger index = [self.masterSTypes indexOfObject:value
										  inSortedRange:range
												options:NSBinarySearchingFirstEqual
										usingComparator:^(id obj1, id obj2) {
											id value1, value2;
											if([obj1 isKindOfClass:[NSNumber class]]) {
												value1 = obj1;
											} else {
												value1 = [obj1 valueForKey:@"id"];
											}
											if([obj2 isKindOfClass:[NSNumber class]]) {
												value2 = obj2;
											} else {
												value2 = [obj2 valueForKey:@"id"];
											}
											return [value1 compare:value2];
										}];
	if(index == NSNotFound) {
		[self log:@"Could not find stype of id (%@)", value];
		return;
	}
	id item = [self.masterSTypes objectAtIndex:index];
	
	[self setValueIfNeeded:item toObject:object forKey:@"stype"];
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
