//
//  HMBorderTextField.m
//  KCD
//
//  Created by Hori,Masaki on 2016/05/04.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMBorderTextField.h"

@implementation HMBorderTextField

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
	
	[[NSColor controlShadowColor] set];
//	NSFrameRect(self.bounds);
	
	NSRect rect = self.bounds;
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect) + 3.0, NSMaxY(rect))
							  toPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))
							  toPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
}

@end
