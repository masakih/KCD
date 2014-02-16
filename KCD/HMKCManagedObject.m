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
	if([inKey isEqualToString:@"api_aftershipid"]) {
		if(![*ioValue isKindOfClass:[NSNumber class]]) {
			id newValue = @([*ioValue integerValue]);
			if(newValue) {
				*ioValue = newValue;
				return YES;
			}
			return NO;
		}
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
	NSLog(@"self dose not have key %@", key);
	return;
#endif
	[super setValue:value forUndefinedKey:key];
}

@end
