//
//  HMUpdateSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMUpdateSlotItemCommand.h"

#import "HMServerDataStore.h"
#import "HMKCMasterSlotItemObject.h"
#import "HMKCSlotItemObject+Extensions.h"

@implementation HMUpdateSlotItemCommand
- (NSString *)dataKey
{
	return @"api_data.api_slot_item";
}
- (void)execute
{
	NSDictionary *data = [self.json valueForKeyPath:self.dataKey];
	if(!data || [data isKindOfClass:[NSNull class]]) return;
	
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSError *error = nil;
	NSArray<HMKCMasterSlotItemObject *> *masterSlotItems = [store objectsWithEntityName:@"MasterSlotItem"
																				  error:&error
																		predicateFormat:@"id = %@", data[@"api_slotitem_id"]];
	if(masterSlotItems.count == 0) {
		NSLog(@"MasterSlotItem is invalid");
		return;
	}
	
	HMKCSlotItemObject *newSlotItem = [NSEntityDescription insertNewObjectForEntityForName:@"SlotItem"
																	inManagedObjectContext:moc];
	newSlotItem.id =  data[@"api_id"];
	newSlotItem.master_slotItem = masterSlotItems[0];
}

@end
