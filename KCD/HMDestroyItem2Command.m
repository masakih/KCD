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
	NSArray *items = [itemsString componentsSeparatedByString:@","];
	
	
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
}
@end
