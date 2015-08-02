//
//  HMMapAreaTransformaer.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/02.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMMapAreaTransformaer.h"

@implementation HMMapAreaTransformaer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMMapAreaTransformaer"];
	});
}
+ (Class)transformedValueClass
{
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	NSInteger areaId = [value integerValue];
	return areaId > 10 ? @"E" : [NSString stringWithFormat:@"%@", value];
}
@end
