//
//  HMLengTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMLengTransformer.h"

typedef NS_ENUM(NSInteger, LengType) {
	kShort = 1,
	kMiddle = 2,
	kLong = 3,
	kOverLong = 4,
};

@implementation HMLengTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMLengTransformer"];
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
	if(![value isKindOfClass:[NSNumber class]]) return nil;
	
	NSString *result = nil;
	LengType leng = [value integerValue];
	switch (leng) {
		case kShort:
			result = NSLocalizedString(@"Short", @"Range, short");
			break;
		case kMiddle:
			result = NSLocalizedString(@"Middle", @"Range, middle");
			break;
		case kLong:
			result = NSLocalizedString(@"Long", @"Range, long");
			break;
		case kOverLong:
			result = NSLocalizedString(@"Very Long", @"Range, very long");
			break;
	}
	
	return result;
}
@end
