//
//  HMKaisouLockCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKaisouLockCommand.h"

#import "KCD-Swift.h"

@implementation HMKaisouLockCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_kaisou/lock"];
}

- (void)execute
{
	NSDictionary *api_data = [self.json valueForKeyPath:self.dataKey];
	if(![api_data isKindOfClass:[NSDictionary class]]) {
		[self log:@"api_data is NOT NSDictionary."];
		return;
	}
	id slotitemId = self.arguments[@"api_slotitem_id"];
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];	
	NSError *error = nil;
	NSArray *result = [serverDataStore objectsWithEntityName:@"SlotItem"
											 sortDescriptors:nil
												   predicate:[NSPredicate predicateWithFormat:@"id = %ld", [slotitemId integerValue]]
													   error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(result.count == 0) {
		[self log:@"Could not find SlotItem number %@", slotitemId];
		return;
	}
	
	BOOL locked = [api_data[@"api_locked"] boolValue];
	[result[0] setValue:@(locked) forKey:@"locked"];
}

@end
