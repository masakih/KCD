//
//  HMMillisecondTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/03.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMMillisecondTransformer.h"

@implementation HMMillisecondTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMMillisecondTransformer"];
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
	NSTimeInterval milliseconds = [value doubleValue];
	
	return @(milliseconds / 1000.0);
	
}
@end
