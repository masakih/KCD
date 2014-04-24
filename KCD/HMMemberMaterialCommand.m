//
//  HMMemberMaterialCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberMaterialCommand.h"

#import "HMServerDataStore.h"

@implementation HMMemberMaterialCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/material"];
}
- (NSString *)dataKey
{
	return @"api_data";
}
- (void)execute
{
	NSArray *api_data = [self.json valueForKeyPath:self.dataKey];
	if(![api_data isKindOfClass:[NSArray class]]) {
		[self log:@"%@ is NOT NSArray.", self.dataKey];
		return;
	}
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *managedObjectContext = [serverDataStore managedObjectContext];
	
	NSError *error = nil;
	id result = [serverDataStore objectsWithEntityName:@"Material" predicate:nil error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	NSManagedObject *object = nil;
	if(!result || [result count] == 0) {
		object = [NSEntityDescription insertNewObjectForEntityForName:@"Material"
											   inManagedObjectContext:managedObjectContext];
	} else {
		object = result[0];
	}
	
	NSArray *keys = @[@"fuel", @"bull", @"steel", @"bauxite", @"kousokukenzo", @"kousokushuhuku", @"kaihatusizai"];
	
	for(NSDictionary *dict in api_data) {
		NSNumber *idValue = [dict valueForKey:@"api_id"];
		NSString *key = keys[[idValue integerValue] - 1];
		[object setValue:[dict valueForKey:@"api_value"] forKey:key];
	}
}
@end
