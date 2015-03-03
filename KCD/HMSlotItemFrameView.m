//
//  HMSlotItemFrameView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/03.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMSlotItemFrameView.h"

@implementation HMSlotItemFrameView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	
	NSRect frame = self.frame;
	[[NSColor gridColor] set];
	[NSBezierPath setDefaultLineWidth:1.0];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(40.5, 0) toPoint:NSMakePoint(40.5, frame.size.height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, 17.5) toPoint:NSMakePoint(frame.size.width, 17.5)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, 34.5) toPoint:NSMakePoint(frame.size.width, 34.5)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, 51.5) toPoint:NSMakePoint(frame.size.width, 51.5)];
	
}

@end
