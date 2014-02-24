//
//  HMMemberBasicCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberBasicCommand.h"

#import "HMCoreDataManager.h"


@implementation HMMemberBasicCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/basic"];
}
- (void)execute
{
	NSDictionary *api_data = [self.json objectForKey:@"api_data"];
	if(![api_data isKindOfClass:[NSDictionary class]]) {
		[self log:@"api_data is NOT NSDictionary."];
		return;
	}
	
	HMCoreDataManager *dm = [HMCoreDataManager oneTimeEditor];
	NSManagedObjectContext *managedObjectContext = [dm managedObjectContext];
	
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Basic"];
	NSError *error = nil;
	id result = [managedObjectContext executeFetchRequest:req
													error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	NSManagedObject *object = nil;
	if(!result || [result count] == 0) {
		object = [NSEntityDescription insertNewObjectForEntityForName:@"Basic"
											   inManagedObjectContext:managedObjectContext];
	} else {
		object = result[0];
	}
	
	for(NSString *key in api_data) {
		id value = api_data[key];
		if([self handleExtraValue:value forKey:key toObject:object]) {
			continue;
		}
		if([value isKindOfClass:[NSArray class]]) {
			NSUInteger i = 0;
			for(id element in value) {
				id hoge = element;
				NSString *newKey = [NSString stringWithFormat:@"%@_%ld", key, i];
				if([object validateValue:&hoge forKey:newKey error:NULL]) {
					[object setValue:hoge forKey:newKey];
				}
				i++;
			}
		} else if([value isKindOfClass:[NSDictionary class]]) {
			for(id subKey in value) {
				id subValue = value[subKey];
				NSString *newKey = [NSString stringWithFormat:@"%@_D_%@", key, keyByDeletingPrefix(subKey)];
				if([object validateValue:&subValue forKey:newKey error:NULL]) {
					[object setValue:subValue forKey:newKey];
				}
			}
		} else {
			if([object validateValue:&value forKey:key error:NULL]) {
				[object setValue:value forKey:key];
			}
		}
	}
}
@end