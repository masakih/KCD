//
//  HMMemberShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberShipCommand.h"

@interface HMMemberShipCommand ()
@property (strong) NSMutableArray *ids;
@end

@implementation HMMemberShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}
+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_get_member/ship"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_get_member/ship2"]) return YES;
	return NO;
}

- (NSArray *)ignoreKeys
{
	static NSArray *ignoreKeys = nil;
	if(ignoreKeys) return ignoreKeys;
	
	ignoreKeys = @[@"api_gomes", @"api_gomes2", @"api_broken", @"api_powup",
				   @"api_voicef", @"api_afterlv", @"api_aftershipid", @"api_backs",
				   @"api_leng", @"api_slotnum", @"api_stype", @"api_name", @"api_yomi",
				   @"api_raig", @"api_luck", @"api_saku", @"api_raim", @"api_baku",
				   @"api_taik", @"api_houg", @"api_souk", @"api_houm", @"api_tyku",
				   @"api_ndock_item", @"api_soku", @"api_star",
				   @"api_ndock_time_str", @"api_member_id", @"api_fuel_max", @"api_bull_max"];
	return ignoreKeys;
}

- (id)init
{
	self = [super init];
	if(self) {
		_ids = [NSMutableArray new];
	}
	return self;
}

- (void)execute
{
	[self commitJSONToEntityNamed:@"Ship"];
}

- (NSString *)dataKey
{
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]) {
		return @"api_data.api_ship";
	}
	return [super dataKey];
}

- (void)setMasterShip:(id)value toObject:(NSManagedObject *)object
{
	id currentValue = [object valueForKeyPath:@"master_ship.name"];
	if(currentValue && ![currentValue isEqual:[NSNull null]]) {
		NSNumber *masterShipId = [object valueForKeyPath:@"master_ship.id"];
		NSNumber *shipId = [object valueForKey:@"ship_id"];
		if([masterShipId isEqual:shipId]) return;
	}
	
	NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
	
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterShip"];
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
		[self log:@"Could not find ship of id (%@)", value];
		return;
	}
	
	[object setValue:result[0] forKey:@"master_ship"];
	[self setValueIfNeeded:value toObject:object forKey:@"ship_id"];
}

- (void)addSlotItem:(id)array toObject:(NSManagedObject *)object
{
	NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"SlotItem"];
	
	NSMutableOrderedSet *orderedSet = [object mutableOrderedSetValueForKey:@"equippedItem"];
	
	NSInteger i = 0;
	NSMutableOrderedSet *newOrderedSet = [NSMutableOrderedSet new];
	for(id value in array) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", value];
		[req setPredicate:predicate];
		NSError *error = nil;
		id result = [managedObjectContext executeFetchRequest:req
														error:&error];
		if(error) {
			[self log:@"Fetch error: %@", error];
			continue;
		}
		if(!result || [result count] == 0) {
			continue;
		}
		
		[newOrderedSet insertObject:result[0] atIndex:i++];
	}
	if(![newOrderedSet isEqual:orderedSet]) {
		NSLog(@"equippedItem did change.");
		[orderedSet removeAllObjects];
		[orderedSet intersectOrderedSet:newOrderedSet];
	}
}

- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	// 取得後破棄した艦娘のデータを削除する
	if([key isEqualToString:@"api_id"]) {
		[self.ids addObject:value];
	}
	
	if([key isEqualToString:@"api_ship_id"]) {
		[self setMasterShip:value toObject:object];
		return YES;
	}
	
	if([key isEqualToString:@"api_exp"]) {
		if(![value isKindOfClass:[NSArray class]]) return NO;
		[self setValueIfNeeded:[value objectAtIndex:0] toObject:object forKey:@"exp"];
		return YES;
	}
	
	if([key isEqualToString:@"api_slot"]) {
		[self addSlotItem:value toObject:object];
		return YES;
	}
	
	return NO;
}

- (void)finishOperating:(NSManagedObjectContext *)moc
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT id IN %@", self.ids];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if(error) {
		NSLog(@"HOGEEEEE");
		return;
	}
	
	for(id obj in array) {
		[moc deleteObject:obj];
	}
	
	if(array.count != 0) {
		NSLog(@"%ld Objects deleted.", array.count);
	}
	
	NSLog(@"updated count -> %ld\ndeleted -> %@", [[moc updatedObjects] count], [moc deletedObjects]);
}

@end
