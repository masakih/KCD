//
//  HMRemodelSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/25.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMRemodelSlotItemCommand.h"

#import "HMServerDataStore.h"
#import "HMKCSlotItemObject+Extensions.h"


@implementation HMRemodelSlotItemCommand
- (void)execute
{
	NSDictionary *api_data = [self.json valueForKeyPath:self.dataKey];
	if(![api_data isKindOfClass:[NSDictionary class]]) {
		[self log:@"api_data is NOT NSDictionary."];
		return;
	}
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSError *error = nil;
	
	// remove use slot items
	NSArray<NSNumber *> *useSlotItemIDs = api_data[@"api_use_slot_id"];
	if([useSlotItemIDs isKindOfClass:[NSArray class]]) {
		NSArray<HMKCSlotItemObject *> *useSlotItems = [serverDataStore objectsWithEntityName:@"SlotItem"
																					   error:&error
																			 predicateFormat:@"id IN %@", useSlotItemIDs];
		[useSlotItems enumerateObjectsUsingBlock:^(HMKCSlotItemObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSManagedObjectContext *con = serverDataStore.managedObjectContext;
			[con deleteObject:obj];
		}];
	}
	
	BOOL success = [api_data[@"api_remodel_flag"] boolValue];
	if(!success) {
		[self log:@"Remodel is failed."];
		return;
	}
	
	id slotitemId = self.arguments[@"api_slot_id"];
	
	error = nil;
	NSArray<HMKCSlotItemObject *> *slotItems = [serverDataStore objectsWithEntityName:@"SlotItem"
																				error:&error
																	  predicateFormat:@"id = %ld", [slotitemId integerValue]];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(slotItems.count == 0) {
		[self log:@"Could not find SlotItem number %@", slotitemId];
		return;
	}
	
	api_data = api_data[@"api_after_slot"];
	
	BOOL locked = [api_data[@"api_locked"] boolValue];
	slotItems[0].locked = @(locked);
	
	NSNumber *masterSoltItemId = api_data[@"api_slotitem_id"];
	if([masterSoltItemId compare:slotItems[0].slotitem_id] != NSOrderedSame) {
		[self setMasterSlotItemForItemID:masterSoltItemId object:slotItems[0] store:serverDataStore];
	}
	
	NSNumber *level = api_data[@"api_level"];
	slotItems[0].level = level;
}

- (void)setMasterSlotItemForItemID:(NSNumber *)slotItemId object:(id)object store:(HMServerDataStore *)serverDataStore
{
	NSError *error = nil;
	NSArray<HMKCSlotItemObject *> *slotItems = [serverDataStore objectsWithEntityName:@"MasterSlotItem"
																				error:&error
																	  predicateFormat:@"id = %ld", [slotItemId integerValue]];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(slotItems.count == 0) {
		[self log:@"Could not find MasterSlotItem number %@", slotItemId];
		return;
	}
	[self setValueIfNeeded:slotItems[0] toObject:object forKey:@"master_slotItem"];
	[self setValueIfNeeded:slotItemId toObject:object forKey:@"slotitem_id"];
}

@end
