//
//  HMSlotItemEquipTypeTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/30.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMSlotItemEquipTypeTransformer.h"

#import "HMServerDataStore.h"

@implementation HMSlotItemEquipTypeTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMSlotItemEquipTypeTransformer"];
	});
}

- (id)transformedValue:(id)value
{
	if(![value isKindOfClass:[NSNumber class]]) return nil;
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"MasterSlotItemEquipType"
											error:&error
								  predicateFormat:@"id = %@", value];
	if([array count] == 0) {
		NSLog(@"MasterSlotItemEquipType is invalid.");
		return nil;
	}
	
	return [array[0] valueForKey:@"name"];
}
@end
