//
//  HMSlotItemShortNameTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2015/10/23.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMSlotItemShortNameTransformer.h"

#import "HMServerDataStore.h"

#import "HMKCSlotItemObject+Extensions.h"
#import "HMKCMasterSlotItemObject.h"

static NSDictionary *slotItemShortName = nil;

@implementation HMSlotItemShortNameTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMSlotItemShortNameTransformer"];
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *path = [mainBundle pathForResource:@"SlotItemShortName" ofType:@"plist"];
		if(!path) {
			NSLog(@"Could not find SlotItemShortName.plist");
			NSBeep();
			return;
		}
		id dict = [NSDictionary dictionaryWithContentsOfFile:path];
		if(!dict) {
			NSLog(@"SlotItemShortName.plist is not dictionay.");
			NSBeep();
			return;
		}
		slotItemShortName = dict;
	});
}

+ (Class)transformedValueClass
{
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	if(![value isKindOfClass:[NSNumber class]]) return nil;
	NSInteger slotItemID = [value integerValue];
	if(slotItemID == -1) return nil;
	if(slotItemID == 0) return nil;
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"SlotItem"
											error:&error
								  predicateFormat:@"id = %@", value];
	if([array count] == 0) {
		NSLog(@"SlotItem is invalid.");
		return nil;
	}
	
	HMKCSlotItemObject *slotItem = array[0];
	NSString *mstIDString = [slotItem.master_slotItem.id stringValue];
	NSString *shortName = slotItemShortName[mstIDString];
	if(shortName) return shortName;
	
	return [slotItem.name copy];
}
@end
