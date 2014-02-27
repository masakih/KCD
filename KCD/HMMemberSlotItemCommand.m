//
//  HMMemberSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/27.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberSlotItemCommand.h"

@implementation HMMemberSlotItemCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/slotitem"];
}

- (NSArray *)ignoreKeys
{
	static NSArray *ignoreKeys = nil;
	if(ignoreKeys) return ignoreKeys;
	
	ignoreKeys = @[@"api_tyku", @"api_raig", @"api_houk", @"api_luck",
				   @"api_souk", @"api_baku", @"api_raik", @"api_leng",
				   @"api_rare", @"api_soku", @"api_taik", @"api_type", @"api_tais",
				   @"api_bakk", @"api_info", @"api_houm", @"api_raim", @"api_broken",
				   @"api_saku", @"api_member_id", @"api_houg", @"api_atap",
				   @"api_name"];
	return ignoreKeys;
}

- (void)execute
{
	[self commitJSONToEntityNamed:@"SlotItem"];
}

- (void)setMasterSlotItem:(id)value toObject:(NSManagedObject *)object
{
	id currentValue = [object valueForKeyPath:@"master_slotItem.name"];
	if(currentValue && ![currentValue isEqual:[NSNull null]]) return;
	
	NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
	
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterSlotItem"];
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
		[self log:@"Could not find slotItem of id (%@)", value];
		return;
	}
	
	[object setValue:result[0] forKey:@"master_slotItem"];
}
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	if([key isEqualToString:@"api_slotitem_id"]) {
		[self setMasterSlotItem:value toObject:object];
		return YES;
	}
	return NO;
}
@end
