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
			color = [NSColor colorWithCalibratedRed:1.000 green:0.956 blue:0.012 alpha:1.000];
			color = [color colorWithAlphaComponent:0.5];
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
	NSBezierPath *path = nil;
	
	switch(self.controlSize) {
		case NSRegularControlSize:
			path = [self pathForRegular];
			break;
		case NSSmallControlSize:
		case NSMiniControlSize:
			path = [self pathForSmall];
			break;
	}
	return path;
}

- (NSBezierPath *)pathForRegular
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
			[path moveToPoint:NSMakePoint(35.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 35.0)];
			[path closePath];
			break;
		case modest:
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(50.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(25.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 25.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 50.0)];
			[path closePath];
			break;
		case badly:
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(60.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(53.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 53.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 60.0)];
			[path closePath];
			
			[path moveToPoint:NSMakePoint(47.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(23.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 23.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 47.0)];
			[path closePath];
			break;
	}
	
	return path;
}

- (NSBezierPath *)pathForSmall
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
			[path moveToPoint:NSMakePoint(35.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 35.0)];
			[path closePath];
			break;
		case modest:
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(50.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(25.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 25.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 50.0)];
			[path closePath];
			break;
		case badly:
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(55.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(48.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 48.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 55.0)];
			[path closePath];
			
			[path moveToPoint:NSMakePoint(42.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(20.0, boundsSize.height - 2.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 20.0)];
			[path lineToPoint:NSMakePoint(0.0, boundsSize.height - 42.0)];
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
