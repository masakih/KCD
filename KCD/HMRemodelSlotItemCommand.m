//
//  HMRemodelSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/25.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMRemodelSlotItemCommand.h"

#import "HMServerDataStore.h"


@implementation HMRemodelSlotItemCommand
- (void)execute
{
	NSDictionary *api_data = [self.json valueForKeyPath:self.dataKey];
	if(![api_data isKindOfClass:[NSDictionary class]]) {
		[self log:@"api_data is NOT NSDictionary."];
		return;
	}
	
	BOOL success = [api_data[@"api_remodel_flag"] boolValue];
	if(!success) {
		[self log:@"Remodel is failed."];
		return;
	}
	
	id slotitemId = self.arguments[@"api_slot_id"];
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSError *error = nil;
	NSArray *result = [serverDataStore objectsWithEntityName:@"SlotItem"
													   error:&error
											 predicateFormat:@"id = %ld", [slotitemId integerValue]];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(result.count == 0) {
		[self log:@"Could not find SlotItem number %@", slotitemId];
		return;
	}
	
	api_data = api_data[@"api_after_slot"];
	
	BOOL locked = [api_data[@"api_locked"] boolValue];
	[result[0] setValue:@(locked) forKey:@"locked"];
	
	NSNumber *masterSoltItemId = api_data[@"api_slotitem_id"];
	if([masterSoltItemId compare:[result[0] valueForKey:@"slotitem_id"]] != NSOrderedSame) {
		[self setMasterSlotItemForItemID:masterSoltItemId object:result[0] store:serverDataStore];
	}
	
	NSNumber *level = api_data[@"api_level"];
	[result[0] setValue:level forKey:@"level"];
}

- (void)setMasterSlotItemForItemID:(NSNumber *)slotItemId object:(id)object store:(HMServerDataStore *)serverDataStore
{
	NSError *error = nil;
	NSArray *result = [serverDataStore objectsWithEntityName:@"MasterSlotItem"
													   error:&error
											 predicateFormat:@"id = %ld", [slotItemId integerValue]];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(result.count == 0) {
		[self log:@"Could not find MasterSlotItem number %@", slotItemId];
		return;
	}
	id item = result[0];
	[self setValueIfNeeded:item toObject:object forKey:@"master_slotItem"];
	[self setValueIfNeeded:slotItemId toObject:object forKey:@"slotitem_id"];
}

@end
