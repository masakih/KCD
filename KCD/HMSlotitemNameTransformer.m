//
//  HMSlotitemNameTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMSlotitemNameTransformer.h"

#import "HMServerDataStore.h"

#import "HMKCSlotItemObject+Extensions.h"
#import "HMKCMasterSlotItemObject.h"

@implementation HMSlotitemNameTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMSlotitemNameTransformer"];
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
	
	return [slotItem.name copy];
}
@end
