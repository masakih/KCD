//
//  HMSlotResetCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/10/30.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMSlotResetCommand.h"

#import "HMServerDataStore.h"
#import "HMKCShipObject+Extensions.h"


@interface HMSlotResetCommand ()
@property (nonatomic, copy) NSArray *slotItems;

@end

@implementation HMSlotResetCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}
+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kaisou/slot_exchange_index"]) return YES;
	return NO;
}

- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	
	NSString *destroyedShipId = [self.arguments objectForKey:@"api_id"];
	
	NSError *error = nil;
	NSArray<HMKCShipObject *> *ships = [store objectsWithEntityName:@"Ship"
															  error:&error
													predicateFormat:@"id = %@", @([destroyedShipId integerValue])];
	if(ships.count == 0) {
		return;
	}
	
	HMKCShipObject *ship = ships[0];
	
	NSArray *slotItems = [self.json valueForKeyPath:@"api_data.api_slot"];
	for(NSUInteger i = 0; i < slotItems.count; i++) {
		NSNumber *slotID = slotItems[i];
		if([slotID integerValue] == -1) continue;
		[ship setValue:slotID forKey:[NSString stringWithFormat:@"slot_%ld", i]];
	}
	
	[self addSlotItem:slotItems toObject:ship];
	
}

- (void)addSlotItem:(id)slotItems toObject:(NSManagedObject *)object
{
	if(!self.slotItems) {
		NSError *error = nil;
		NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"SlotItem"];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
		[req setSortDescriptors:@[sortDescriptor]];
		self.slotItems = [managedObjectContext executeFetchRequest:req
															 error:&error];
		if(error) {
			[self log:@"Fetch error: %@", error];
			return;
		}
		if([self.slotItems count] == 0) {
			return;
		}
	}
	
	NSMutableArray *newItems = [NSMutableArray new];
	NSRange range = NSMakeRange(0, self.slotItems.count);
	for(id value in slotItems) {
		if([value integerValue] == -1) continue;
		NSUInteger index = [self.slotItems indexOfObject:value
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
			id lastItem = [self.slotItems lastObject];
			NSInteger lastItemId = [[lastItem valueForKey:@"id"] integerValue];
			if(lastItemId < [value integerValue]) {
#if DEBUG
				[self log:@"item is maybe unregistered, so it is new ship's equipment."];
#endif
			} else {
				[self log:@"Item %@ is not found.", value];
			}
			continue;
		}
		id item = [self.slotItems objectAtIndex:index];
		
		[newItems addObject:item];
	}
	
	NSMutableOrderedSet *orderedSet = [object mutableOrderedSetValueForKey:@"equippedItem"];
	[orderedSet removeAllObjects];
	[orderedSet addObjectsFromArray:newItems];
}
@end
