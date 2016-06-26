//
//  HMHistoryMarkTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2016/06/26.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMHistoryMarkTransformer.h"

@implementation HMHistoryMarkTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMHistoryMarkTransformer"];
	});
}
+ (Class)transformedValueClass
{
	return [NSImage class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (NSImage *)markImage
{
	const CGFloat radius = 10;
	NSImage *mark = [[NSImage alloc] initWithSize:NSMakeSize(radius, radius)];
	[mark lockFocus];
	{
		[[NSColor redColor] set];
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, radius, radius)
															 xRadius:radius / 2
															 yRadius:radius / 2];
		[path fill];
	}
	[mark unlockFocus];
	
	return mark;
}

- (id)transformedValue:(id)value
{
	BOOL mark = [value boolValue];
	
	return mark ? self.markImage : nil;
	
}
@end
