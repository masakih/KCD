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
    kFaster = 15,
    kFastest = 20,
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
			result = NSLocalizedString(@"Slow", @"Speed, slow");
			break;
		case kFast:
			result = NSLocalizedString(@"Fast", @"Speed, fast");
			break;
        case kFaster:
            result = NSLocalizedString(@"Faster", @"Speed, faster");
            break;
        case kFastest:
            result = NSLocalizedString(@"Fastest", @"Speed, fastest");
            break;
	}
	
	return result;
}
@end
