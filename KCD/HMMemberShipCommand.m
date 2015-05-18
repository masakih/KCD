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

@property (nonatomic, strong) NSArray *masterShips;
@property (nonatomic, strong) NSArray *slotItems;
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
	if([self.api isEqualToString:@"/kcsapi/api_get_member/ship3"]) {
		return @"api_data.api_ship_data";
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_kousyou/getship"]) {
		return @"api_data.api_ship";
	}
	if([self.api isEqualToString:@"/kcsapi/api_get_member/ship_deck"]) {
		return @"api_data.api_ship_data";
	}
	return [super dataKey];
}

- (void)setMasterShip:(id)value toObject:(NSManagedObject *)object
{
	id currentValue = [object valueForKeyPath:@"master_ship.name"];
	if(currentValue && ![currentValue isEqual:[NSNull null]]) {
		NSNumber *shipId = [object valueForKey:@"ship_id"];
		if([value isEqual:shipId]) return;
	}
	
	if(!self.masterShips) {
		NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterShip"];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
		[req setSortDescriptors:@[sortDescriptor]];
		NSError *error = nil;
		self.masterShips = [managedObjectContext executeFetchRequest:req
														error:&error];
		if(error) {
			[self log:@"Fetch error: %@", error];
			return;
		}
		if(!self.masterShips || [self.masterShips count] == 0) {
			[self log:@"MasterShip is invalidate"];
			return;
		}
	}
	
	NSRange range = NSMakeRange(0, self.masterShips.count);
	NSUInteger index = [self.masterShips indexOfObject:value
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
		[self log:@"Could not find ship of id (%@)", value];
		return;
	}
	id item = [self.masterShips objectAtIndex:index];
	
	[self setValueIfNeeded:item toObject:object forKey:@"master_ship"];
	[self setValueIfNeeded:value toObject:object forKey:@"ship_id"];
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
		return NO;
	}
	
	return NO;
}

static BOOL isFewShipUpdateAPI(NSString *api)
{
	if([api isEqualToString:@"/kcsapi/api_get_member/ship3"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_req_kousyou/getship"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_get_member/ship_deck"]) return YES;
	
	return NO;
}
- (void)finishOperating:(NSManagedObjectContext *)moc
{
	// ship3の時は1隻のみのデータアップデートがあるため
	// getshipの時は取得した1隻のみのデータのため
	if(isFewShipUpdateAPI(self.api)) {
		return;
	}
	
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
	
//	if(array.count != 0) {
//		NSLog(@"%ld Objects deleted.", array.count);
//	}
//	
//	NSLog(@"updated count -> %ld\ndeleted -> %@", [[moc updatedObjects] count], [moc deletedObjects]);
}

@end
