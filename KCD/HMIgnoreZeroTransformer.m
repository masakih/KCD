//
//  HMIgnoreZeroTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/25.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMIgnoreZeroTransformer.h"

@implementation HMIgnoreZeroTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMIgnoreZeroTransformer"];
	});
}
+ (Class)transformedValueClass
{
	return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	if(![value isKindOfClass:[NSNumber class]]) return nil;
	
	if([value integerValue] == 0) return nil;
	
	return value;
}
@end
