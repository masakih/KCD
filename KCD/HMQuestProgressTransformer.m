//
//  HMQuestProgressTransformar.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/07.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMQuestProgressTransformer.h"

@implementation HMQuestProgressTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMQuestProgressTransformer"];
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
	NSInteger flag = [value integerValue];
	switch (flag) {
		case 3:
			result = @"100%";
			break;
		case 5:
		case 6:
			result = @"50%";
			break;
		case 9:
		case 10:
			result = @"80%";
			break;
		default:
			result = @"";
			break;
			
	}
	
	return result;
}
@end
