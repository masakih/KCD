//
//  HMMaserShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMaserShipCommand.h"

static NSCondition *sCondition = nil;

@implementation HMMaserShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
		sCondition = [NSCondition new];
	});
}
+ (NSCondition *)condition
{
	return sCondition;
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_master/ship"];
}

- (void)execute
{
	dispatch_queue_t queue = dispatch_queue_create("HMMaserShipCommand", 0);
	dispatch_async(queue, ^{
		[sCondition lock];
		[sCondition wait];
		[sCondition unlock];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self realExecute];
		});
		sCondition = nil;
	});
}

- (void)setStype:(id)value toObject:(id)object
{
	NSManagedObjectContext *managedObjectContext = [[NSApp delegate] managedObjectContext];
	
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterSType"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", value];
	[req setPredicate:predicate];
	NSError *error = nil;
	id result = [managedObjectContext executeFetchRequest:req
													error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(!result || [result count] == 0) {
		[self log:@"Could not find stype of id (%@)", value];
		return;
	}
	
	[object setValue:result[0] forKey:@"api_stype"];
}
- (void)realExecute
{
	NSArray *api_data = [self.json objectForKey:@"api_data"];
	if(![api_data isKindOfClass:[NSArray class]]) {
		[self log:@"api_data is NOT NSArray."];
		return;
	}
	
	NSManagedObjectContext *managedObjectContext = [[NSApp delegate] managedObjectContext];
	
	for(NSDictionary *type in api_data) {
		NSString *stypeID = type[@"api_id"];
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterShip"];
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
			object = [NSEntityDescription insertNewObjectForEntityForName:@"MasterShip"
												   inManagedObjectContext:managedObjectContext];
		} else {
			object = result[0];
		}
		
		for(NSString *key in type) {
			id value = type[key];
			if([key isEqualToString:@"api_stype"]) {
				[self setStype:value toObject:object];
				continue;
			}
			if([value isKindOfClass:[NSArray class]]) {
				NSUInteger i = 0;
				for(id element in value) {
					id hoge =element;
					if([object validateValue:&hoge forKey:key error:NULL]) {
						[object setValue:hoge forKey:[NSString stringWithFormat:@"%@%ld", key, i]];
					}
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
