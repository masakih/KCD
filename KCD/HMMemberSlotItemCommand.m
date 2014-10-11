//
//  HMMemberSlotItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/27.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberSlotItemCommand.h"

@interface HMMemberSlotItemCommand ()
@property (strong) NSMutableArray *ids;

@property (nonatomic, strong) NSArray *masterSlotItems;
@end

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
	return [api isEqualToString:@"/kcsapi/api_get_member/slot_item"];
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
	[self commitJSONToEntityNamed:@"SlotItem"];
}

- (void)setMasterSlotItem:(id)value toObject:(NSManagedObject *)object
{
	id currentValue = [object valueForKeyPath:@"master_slotItem.name"];
	if(currentValue && ![currentValue isEqual:[NSNull null]]) {
		return;
	}
	
	if(!self.masterSlotItems) {
		NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterSlotItem"];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
		[req setSortDescriptors:@[sortDescriptor]];
		NSError *error = nil;
		self.masterSlotItems = [managedObjectContext executeFetchRequest:req
																   error:&error];
		if(error) {
			[self log:@"Fetch error: %@", error];
			return;
		}
		if(!self.masterSlotItems || [self.masterSlotItems count] == 0) {
			[self log:@"MasterSlotItem is Invalidate"];
			return;
		}
	}
	
	NSRange range = NSMakeRange(0, self.masterSlotItems.count);
	NSUInteger index = [self.masterSlotItems indexOfObject:value
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
		[self log:@"Could not find slotItem of id (%@)", value];
		return;
	}
	id item = [self.masterSlotItems objectAtIndex:index];
	[self setValueIfNeeded:item toObject:object forKey:@"master_slotItem"];
	[self setValueIfNeeded:value toObject:object forKey:@"slotitem_id"];
}
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	// 取得後破棄した艦娘のデータを削除する
	if([key isEqualToString:@"api_id"]) {
		[self.ids addObject:value];
		return NO;
	}
	
	if([key isEqualToString:@"api_slotitem_id"]) {
		[self setMasterSlotItem:value toObject:object];
		return YES;
	}
	return NO;
}

- (void)finishOperating:(NSManagedObjectContext *)moc
{	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SlotItem"];
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
}

@end
