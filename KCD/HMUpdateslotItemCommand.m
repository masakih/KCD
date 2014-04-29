//
//  HMUpdateslotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMUpdateslotItemCommand.h"

#import "HMServerDataStore.h"

@implementation HMUpdateslotItemCommand
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
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MasterSlotItem"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", data[@"api_slotitem_id"]];
	[request setPredicate:predicate];
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if([array count] == 0) {
		NSLog(@"MasterSlotItem is invalid");
		return;
	}
	
	id object = [NSEntityDescription insertNewObjectForEntityForName:@"SlotItem"
											  inManagedObjectContext:moc];
	[object setValue:data[@"api_id"] forKey:@"id"];
	[object setValue:array[0] forKey:@"master_slotItem"];
}

@end
