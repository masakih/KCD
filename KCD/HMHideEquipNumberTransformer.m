//
//  HMHideEquipNumberTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMHideEquipNumberTransformer.h"
#import "HMServerDataStore.h"

#import "HMKCSlotItemObject+Extensions.h"
#import "HMKCMasterSlotItemObject.h"

static NSArray *showsTypes = nil;

@implementation HMHideEquipNumberTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMHideEquipNumberTransformer"];
		
		showsTypes = @[@6, @7, @8, @9, @10, @11, @25, @26, @41, @45];
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
	if(slotItemID == -1) return @YES;
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"SlotItem"
											error:&error
								  predicateFormat:@"id = %@", value];
	if([array count] == 0) {
		NSLog(@"SlotItem is invalid.");
		return nil;
	}
	HMKCSlotItemObject *item = array[0];
	
	return @(![showsTypes containsObject:item.master_slotItem.type_2]);
}
@end
