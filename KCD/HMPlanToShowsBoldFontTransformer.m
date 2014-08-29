//
//  HMPlanToShowsBoldFontTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2014/08/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPlanToShowsBoldFontTransformer.h"

@implementation HMPlanToShowsBoldFontTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMPlanToShowsBoldFontTransformer"];
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
	if(![value isKindOfClass:[NSNumber class]]) return @NO;
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if(![ud boolForKey:@"showsPlanColor"]) return @NO;
	
	if([value integerValue] == 0) return @NO;
	
	return @YES;
}
@end
