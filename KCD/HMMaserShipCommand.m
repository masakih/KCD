//
//  HMMaserShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMaserShipCommand.h"

#import "HMMemberShipCommand.h"


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
		
		[self realExecute];
		
		sCondition = nil;
	});
}

- (void)setStype:(id)value toObject:(NSManagedObject *)object
{
	id currentValue = [object valueForKeyPath:@"stype.name"];
	if(currentValue && ![currentValue isEqual:[NSNull null]]) return;
	
	NSManagedObjectContext *managedObjectContext = [object managedObjectContext];
	
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
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	if([key isEqualToString:@"api_stype"]) {
		[self setStype:value toObject:object];
		return YES;
	}
	return NO;
}
- (void)realExecute
{
	[self commitJSONToEntityNamed:@"MasterShip"];
		
	NSCondition *lock = [HMMemberShipCommand condition];
	[lock lock];
	[lock broadcast];
	[lock unlock];
}

@end
