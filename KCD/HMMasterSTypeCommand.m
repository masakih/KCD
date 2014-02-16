//
//  HMMasterSTypeCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/13.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterSTypeCommand.h"

#import "HMMaserShipCommand.h"

#import "HMAppDelegate.h"


@implementation HMMasterSTypeCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_master/stype"];
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
		NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"MasterSType"];
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
			object = [NSEntityDescription insertNewObjectForEntityForName:@"MasterSType"
												   inManagedObjectContext:managedObjectContext];
		} else {
			object = result[0];
		}
		
		for(NSString *key in type) {
			[object setValue:type[key] forKey:key];
		}
	}
	[managedObjectContext save:NULL];
	
	NSCondition *lock = [HMMaserShipCommand condition];
	[lock lock];
	[lock broadcast];
	[lock unlock];
}
@end
