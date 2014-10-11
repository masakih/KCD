//
//  HMKCSlotItemObject+Extensions.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCSlotItemObject+Extensions.h"

#import "HMKCShipObject+Extensions.h"

#import "HMServerDataStore.h"

static NSMutableDictionary *names = nil;

@implementation HMKCSlotItemObject (Extensions)
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		names = [NSMutableDictionary new];
	});
}

- (NSString *)name
{
	NSNumber *slotItemId = self.slotitem_id;
	if(!slotItemId || [slotItemId isKindOfClass:[NSNull class]]) return nil;
	
	@synchronized(names) {
		NSString *name = names[slotItemId];
		if(name) return name;
	}
	
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"MasterSlotItem"
											error:&error
								  predicateFormat:@"id = %@", slotItemId];
	if([array count] == 0) {
		NSLog(@"MasterSlotItem is invalid.");
		return nil;
	}
	
	NSString *name = [[array[0] valueForKey:@"name"] copy];
	@synchronized(names) {
		names[slotItemId] = name;
	}
	
	return name;
}

- (NSString *)equippedShipName
{
	return self.equippedShip.name;
}
- (NSNumber *)masterSlotItemRare
{
	return [self.master_slotItem valueForKey:@"rare"];
}
- (NSNumber *)isLocked
{
	return self.locked;
}
- (void)setIsLocked:(NSNumber *)isLocked {}

@end
