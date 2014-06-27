//
//  HMKCManagedObject.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCManagedObject.h"

#import "HMJSONCommand.h"


@implementation HMKCManagedObject


- (BOOL)validateValue:(inout id *)ioValue forKey:(NSString *)inKey error:(out NSError **)outError
{
	
	NSArray *t = @[@"api_enqflg", @"api_aftershipid", @"api_progress",
				   @"api_usebull",
//				   @"api_next_rate_0", @"api_next_rate_1", @"api_next_rate_2",
//				   @"api_req_shiptype_0", @"api_req_shiptype_1", @"api_req_shiptype_2", @"api_req_shiptype_3", @"api_req_shiptype_4", @"api_req_shiptype_5",
//				   @"api_next_rate_req_0", @"api_next_rate_req_1", @"api_next_rate_req_2",
//				   @"api_link_no_0", @"api_link_no_1",
				   @"api_flagship", @"api_name_id",
				   @"api_comment_id", @"api_nickname_id", @"api_member_id",
				   @"api_flag_0", @"api_flag_1", @"api_flag_2", @"api_flag_3", @"api_flag_4",
				   @"api_flag_5", @"api_flag_6", @"api_flag_7"];
	if([t containsObject:inKey]) {
		if(![*ioValue isKindOfClass:[NSNumber class]]) {
			id newValue = @([*ioValue integerValue]);
			if(newValue) {
				*ioValue = newValue;
				return YES;
			}
			return NO;
		}
	}
	if([*ioValue isKindOfClass:[NSNull class]]) {
		*ioValue = nil;
		return YES;
	}
	
	return YES;
}

- (id)valueForUndefinedKey:(NSString *)key
{
	if([key isEqualToString:@"description"]) {
		return [self valueForKey:@"description_"];
	}
	if([key hasPrefix:@"api_"]) {
		return [self valueForKey:keyByDeletingPrefix(key)];
	}
	
	NSEntityDescription *entity = [self entity];
	NSLog(@"Entity %@ dose not have key %@", entity.name, key);
	return nil;
	
//	return [super valueForUndefinedKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if([key hasPrefix:@"api_"]) {
		if([key length] < 5) {
			NSLog(@"????");
			return;
		}
		[self setValue:value forKey:keyByDeletingPrefix(key)];
		return;
	}
	if([key isEqualToString:@"description"]) {
		[self setValue:value forKey:@"description_"];
		return;
	}
	
	NSEntityDescription *entity = [self entity];
	NSLog(@"Entity %@ dose not have key %@, value class is %@, value is '%@'", entity.name, key, NSStringFromClass([value class]), value);
//	return;
//	[super setValue:value forUndefinedKey:key];
}

@end
