//
//  HMStrengthenListItemView.m
//  KCD
//
//  Created by Hori,Masaki on 2016/01/01.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMStrengthenListItemView.h"

@implementation HMStrengthenListItemView

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	NSRect bounds = self.bounds;
	
//	[[NSColor controlLightHighlightColor] setFill];
	[[NSColor gridColor] setStroke];
	
//	[NSBezierPath fillRect:bounds];
	
	[NSBezierPath setDefaultLineWidth:1.0];
	[NSBezierPath strokeRect:bounds];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, 17.5) toPoint:NSMakePoint(bounds.size.width, 17.5)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, 34.5) toPoint:NSMakePoint(bounds.size.width, 34.5)];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(29.5, 0) toPoint:NSMakePoint(29.5, bounds.size.height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(67.5, 0) toPoint:NSMakePoint(67.5, bounds.size.height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(206.5, 0) toPoint:NSMakePoint(206.5, bounds.size.height)];
	
}

@end
