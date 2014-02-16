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
	
	[super setValue:value forUndefinedKey:key];
}

@end
