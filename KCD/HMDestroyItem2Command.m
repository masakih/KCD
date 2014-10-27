//
//  HMDestroyItem2Command.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDestroyItem2Command.h"

#import "HMServerDataStore.h"


@implementation HMDestroyItem2Command
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_kousyou/destroyitem2"]) return YES;
	
	return NO;
}
- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSString *itemsString = self.arguments[@"api_slotitem_ids"];
	NSArray *itemsStrings = [itemsString componentsSeparatedByString:@","];
	NSMutableArray *items = [NSMutableArray new];
	for(id item in itemsStrings) {
		[items addObject:@([item integerValue])];
	}
	
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"SlotItem"
										   error:&error
								 predicateFormat:@"id IN %@", items];
	if([array count] == 0) {
		NSLog(@"SlotItem is invalid.");
		return;
	}
	
	for(id obj in array) {
		[moc deleteObject:obj];
	}
	
	//
	error = nil;
	array = [store objectsWithEntityName:@"Material" predicate:nil error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if([array count] == 0) {
		NSLog(@"SlotItem is invalid.");
		return;
	}
	
	id material = array[0];
	NSArray *keys = @[@"fuel", @"bull", @"steel", @"bauxite", @"kousokukenzo", @"kousokushuhuku", @"kaihatusizai", @"screw"];
	
	NSArray *materials = [self.json valueForKeyPath:@"api_data.api_get_material"];
	for(NSInteger i = 0; i < 4; i++) {
		NSInteger current = [[material valueForKey:keys[i]] integerValue];
		NSInteger increase = [materials[i] integerValue];
		[material setValue:@(current + increase) forKey:keys[i]];
	}
}
@end
