//
//  HMMemberMaterialCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberMaterialCommand.h"

#import "HMCoreDataManager.h"

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
- (void)execute
{
	NSArray *api_data = [self.json objectForKey:@"api_data"];
	if(![api_data isKindOfClass:[NSArray class]]) {
		[self log:@"api_data is NOT NSArray."];
		return;
	}
	
	HMCoreDataManager *dm = [HMCoreDataManager oneTimeEditor];
	NSManagedObjectContext *managedObjectContext = [dm managedObjectContext];
	
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Material"];
	NSError *error = nil;
	id result = [managedObjectContext executeFetchRequest:req
													error:&error];
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
