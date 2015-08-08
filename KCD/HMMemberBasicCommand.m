//
//  HMMemberBasicCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberBasicCommand.h"

#import "HMServerDataStore.h"


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
	if([api isEqualToString:@"/kcsapi/api_get_member/basic"]) return YES;
	return NO;
}
- (NSString *)dataKey
{
	if([self.api isEqualToString:@"/kcsapi/api_get_member/basic"]) {
		return @"api_data";
	}
	return @"api_data.api_basic";
}
- (void)execute
{
	NSDictionary *data = [self.json valueForKeyPath:self.dataKey];
	if(![data isKindOfClass:[NSDictionary class]]) {
		[self log:@"api_data is NOT NSDictionary."];
		return;
	}
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *managedObjectContext = [serverDataStore managedObjectContext];
	
	NSError *error = nil;
	NSArray *result = [serverDataStore objectsWithEntityName:@"Basic" predicate:nil error:&error];
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
	
	[self registerElement:data
				 toObject:object];
}
@end
