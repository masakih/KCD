//
//  HMSokuTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMSokuTransformer.h"

typedef NS_ENUM(NSInteger, SokuType) {
	kSlow = 5,
	kFast = 10,
};

@implementation HMSokuTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMSokuTransformer"];
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
	SokuType soku = [value integerValue];
	switch (soku) {
		case kSlow:
			result = @"低速";
			break;
		case kFast:
			result = @"高速";
			break;
	}
	
	return result;
}
@end
