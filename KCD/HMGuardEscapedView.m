//
//  HMGuardEscapedView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/10.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMGuardEscapedView.h"


@implementation HMGuardEscapedView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	
	NSRect bounds = self.bounds;
	
	NSBezierPath *fillPath = [NSBezierPath bezierPathWithRect:bounds];
	[[NSColor colorWithCalibratedWhite:0.9 alpha:0.8] set];
	[fillPath fill];
	
	NSAffineTransform *rotate = [NSAffineTransform transform];
	[rotate translateXBy:0.0 yBy:65.0];
	[rotate rotateByDegrees:-27];
	[rotate concat];
	
	const CGFloat width = 50;
	const CGFloat height = 100;
	NSRect rect = NSMakeRect(
							 (NSInteger)((bounds.size.width - width) * 0.5),
							 (NSInteger)((bounds.size.height - height) * 0.5),
							 width, height);
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
	
	[[NSColor whiteColor] set];
	[path fill];
	
	[[NSColor blackColor] set];
	[path stroke];
	
	rect = NSInsetRect(rect, 3, 3);
	path = [NSBezierPath bezierPathWithRect:rect];
	path.lineWidth = 2;
	[path stroke];
	
	NSDictionary *taiAttr = @{
							  NSForegroundColorAttributeName : [NSColor lightGrayColor],
							  NSFontAttributeName : [NSFont boldSystemFontOfSize:width - 10],
							  };
	NSAttributedString *tai = [[NSAttributedString alloc] initWithString:@"退" attributes:taiAttr];
	
	NSAttributedString *hi = [[NSAttributedString alloc] initWithString:@"避" attributes:taiAttr];
	
	rect = NSInsetRect(rect, 2, 2);
	rect.origin.y += 4;
	rect.size.height -= 2;
	[tai drawInRect:rect];
	rect.size.height *= 0.5;
	[hi drawInRect:rect];
}

@end
