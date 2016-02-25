//
//  HMDamageValueTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMDamageValueTransformer.h"

@implementation HMDamageValueTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMDamageValueTransformer"];
	});
}
+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (NSParagraphStyle *)paragraphStyle
{
	static NSParagraphStyle *style = nil;
	if(!style) {
		NSMutableParagraphStyle *s = [NSMutableParagraphStyle new];
		s.alignment = NSTextAlignmentCenter;
		style = s;
	}
	return style;
}

- (id)transformedValue:(id)value
{
	NSInteger damage = [value integerValue];
	
	NSString *mark = nil;
	NSDictionary *attr = nil;
	
	switch(damage) {
		case 0:
			return nil;
			break;
		case 1:
//			mark = @"•";
			mark = @"●";
			attr = @{
					 NSForegroundColorAttributeName:
						 [NSColor colorWithCalibratedRed:1.000 green:0.925 blue:0.000 alpha:1.000],
					 NSParagraphStyleAttributeName: self.paragraphStyle
					 };
			break;
		case 2:
			mark = @"●";
			attr = @{
					 NSForegroundColorAttributeName:
						 [NSColor colorWithCalibratedRed:1.000 green:0.392 blue:0.000 alpha:1.000],
					 NSParagraphStyleAttributeName: self.paragraphStyle
					 };
			break;
		case 3:
			mark = @"◼︎";
			attr = @{
					 NSForegroundColorAttributeName:
						 [NSColor colorWithCalibratedRed:0.870 green:0.000 blue:0.036 alpha:1.000],
					 NSParagraphStyleAttributeName: self.paragraphStyle
					 };
			break;
		default:
			NSLog(@"Unknown status");
			return nil;
			break;
	}
	
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:mark
																			   attributes:attr];
	
	return result;
}
@end
