//
//  HMDamegeView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/10/18.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMDamageView.h"

@implementation HMDamageView


//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//	self = [super initWithCoder:coder];
//	_damageType = badly;
//	return self;
//}
//- (instancetype)initWithFrame:(NSRect)frameRect
//{
//	self = [super initWithFrame:frameRect];
//	_damageType = badly;
//	return self;
//
//}

- (void)drawRect:(NSRect)dirtyRect
{
	[self.color setFill];
	[self.borderColor setStroke];
	NSBezierPath *path = self.path;
	[path fill];
	[path stroke];
}

- (NSColor *)color
{
	NSColor *color = nil;
	switch(self.damageType) {
		case none:
			return nil;
			break;
		case slightly:
			color = [NSColor yellowColor];
			color = [color colorWithAlphaComponent:0.5];
//			color = [NSColor colorWithCalibratedRed:0.99 green:0.9 blue:0.0 alpha:0.5];
			break;
		case modest:
			color = [NSColor orangeColor];
			color = [color colorWithAlphaComponent:0.5];
			break;
		case badly:
			color = [NSColor redColor];
			color = [color colorWithAlphaComponent:0.5];
			break;
	}
	
	return color;
}

- (NSColor *)borderColor
{
	NSColor *color = nil;
	switch(self.damageType) {
		case none:
			return nil;
			break;
		case slightly:
//			color = [NSColor yellowColor];
			color = [NSColor orangeColor];
			color = [color colorWithAlphaComponent:0.50];
			break;
		case modest:
			color = [NSColor orangeColor];
			color = [color colorWithAlphaComponent:0.9];
			break;
		case badly:
			color = [NSColor redColor];
			color = [color colorWithAlphaComponent:0.9];
			break;
	}
	
	return color;
}

- (NSBezierPath *)path
{
	NSRect bounds = self.bounds;
	NSSize boundsSize = bounds.size;
	NSBezierPath *path = nil;
	
	switch(self.damageType) {
		case none:
			return nil;
			break;
		case slightly:
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(boundsSize.width - 35.0, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 35.0)];
			[path closePath];
			break;
		case modest:
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(boundsSize.width - 50.0, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 25.0, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 25.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 50.0)];
			[path closePath];
			break;
		case badly:
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(boundsSize.width - 60.0, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 55.0, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 55.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 60.0)];
			[path closePath];
			
			[path moveToPoint:NSMakePoint(boundsSize.width - 50.0, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 25.0, 0.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 25.0)];
			[path lineToPoint:NSMakePoint(boundsSize.width - 2, 50.0)];
			[path closePath];
			break;
	}
	
	return path;
}

- (void)setDamageType:(HMDamageType)damageType
{
	if(_damageType != damageType) {
		self.needsDisplay = YES;
	}
	_damageType = damageType;
}
@end
