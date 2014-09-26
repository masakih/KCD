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
	if([api isEqualToString:@"/kcsapi/api_get_member/material"]) return YES;
//	if([api isEqualToString:@"/kcsapi/api_req_hokyu/charge"]) return YES;
	return NO;
}
- (NSString *)dataKey
{
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_kousyou/createitem"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_kousyou/destroyship"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_hokyu/charge"]) {
		return @"api_data.api_material";
	}
	return [super dataKey];
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
	
	NSArray *keys = @[@"fuel", @"bull", @"steel", @"bauxite", @"kousokukenzo", @"kousokushuhuku", @"kaihatusizai", @"DUMMY"];
	
	NSInteger i = 0;
	for(id dict in api_data) {
		if([dict isKindOfClass:[NSDictionary class]]) {
			NSNumber *idValue = [dict valueForKey:@"api_id"];
			NSString *key = keys[[idValue integerValue] - 1];
			if([key isEqualToString:@"DUMMY"]) continue;
			[object setValue:[dict valueForKey:@"api_value"] forKey:key];
		} else {
			NSString *key = keys[i++];
			if([key isEqualToString:@"DUMMY"]) continue;
			[object setValue:@([dict integerValue]) forKey:key];
		}
	}
}
@end
