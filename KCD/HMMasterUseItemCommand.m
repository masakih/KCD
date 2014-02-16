//
//  HMMasterUseItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterUseItemCommand.h"

@implementation HMMasterUseItemCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_master/useitem"];
}
- (void)execute
{
	NSArray *api_data = [self.json objectForKey:@"api_data"];
	if(![api_data isKindOfClass:[NSArray class]]) {
		[self log:@"api_data is NOT NSArray."];
		return;
	}
	
	NSManagedObjectContext *managedObjectContext = [[NSApp delegate] managedObjectContext];
	
	for(NSDictionary *type in api_data) {
		NSString *stypeID = type[@"api_id"];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterUseItem"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", stypeID];
		[req setPredicate:predicate];
		NSError *error = nil;
		id result = [managedObjectContext executeFetchRequest:req
														error:&error];
		if(error) {
			[self log:@"Fetch error: %@", error];
			continue;
		}
		NSManagedObject *object = nil;
		if(!result || [result count] == 0) {
			object = [NSEntityDescription insertNewObjectForEntityForName:@"MasterUseItem"
												   inManagedObjectContext:managedObjectContext];
		} else {
			object = result[0];
		}
		
		
		for(NSString *key in type) {
			id value = type[key];
			if([value isKindOfClass:[NSArray class]]) {
				//
				NSUInteger i = 0;
				for(id element in value) {
					[object setValue:value[i] forKey:[NSString stringWithFormat:@"%@%ld", key, i]];
					i++;
				}
			} else {
				if([object validateValue:&value forKey:key error:NULL]) {
					[object setValue:value forKey:key];
				}
			}
		}
	}
}
@end
