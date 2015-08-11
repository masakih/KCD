//
//  HMHaihiView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/10.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMHaihiView.h"

@implementation HMHaihiView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	
	NSRect frame = self.frame;
	
	NSBezierPath *fillPath = [NSBezierPath bezierPathWithRect:frame];
	[[NSColor colorWithCalibratedWhite:0.9 alpha:0.8] set];
	[fillPath fill];
	
	NSAffineTransform *rotate = [NSAffineTransform transform];
	[rotate translateXBy:0.0 yBy:65.0];
	[rotate rotateByDegrees:-27];
	[rotate concat];
	
	const CGFloat width = 50;
	const CGFloat height = 100;
	NSRect rect = NSMakeRect(
							 (NSInteger)((frame.size.width - width) * 0.5),
							 (NSInteger)((frame.size.height - height) * 0.5),
							 width, height);
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
	
	
	NSShadow *shadow = [NSShadow new];
	shadow.shadowOffset = NSMakeSize(1, -3);
	shadow.shadowColor = [NSColor darkGrayColor];
	shadow.shadowBlurRadius = 5;
	[shadow set];
	
	[[NSColor whiteColor] set];
	[path fill];
	
	shadow = [NSShadow new];
	[shadow set];
	
	[[NSColor blackColor] set];
	[path stroke];
	
	rect = NSInsetRect(rect, 3, 3);
	path = [NSBezierPath bezierPathWithRect:rect];
	path.lineWidth = 2;
	[path stroke];
	
	NSDictionary *taiAttr = @{
							  NSForegroundColorAttributeName : [NSColor colorWithCalibratedRed:0 green:204 / 255.0 blue:255 / 255.0 alpha:1],
							  NSFontAttributeName : [NSFont boldSystemFontOfSize:width - 10],
							  };
	NSAttributedString *tai = [[NSAttributedString alloc] initWithString:@"退" attributes:taiAttr];
	
	NSAttributedString *hi = [[NSAttributedString alloc] initWithString:@"避" attributes:taiAttr];
	
	rect = NSInsetRect(rect, 2, 2);
	rect.origin.y += 4;
	rect.size.height -= 2;
	[tai drawInRect:rect];
	rect.size.height *= 0.5;
//	rect.size.height += 2;
	[hi drawInRect:rect];
}

@end
