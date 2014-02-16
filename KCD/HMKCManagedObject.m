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
	NSArray *t = @[@"api_enqflg", @"api_aftershipid", @"api_progress", @"api_usebull"];
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
	if([key hasPrefix:@"api_"]) {
		return [self valueForKey:keyByDeletingPrefix(key)];
	}
	
	return [super valueForUndefinedKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if([key hasPrefix:@"api_"]) {
		[self setValue:value forKey:keyByDeletingPrefix(key)];
		return;
	}
#ifdef DEBUG
	NSLog(@"self dose not have key %@, value class is %@, value is '%@'", key, NSStringFromClass([value class]), value);
	return;
#endif
	[super setValue:value forUndefinedKey:key];
}

@end
