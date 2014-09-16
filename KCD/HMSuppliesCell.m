//
//  HMSuppliesCell.m
//  UITest
//
//  Created by Hori,Masaki on 2014/07/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMSuppliesCell.h"

#import "HMKCShipObject+Extensions.h"

@implementation HMSuppliesCell

- (NSColor *)redColor
{
	return [NSColor colorWithCalibratedWhite:0.39 alpha:1.000];
}
- (NSColor *)orangeColor
{
	return [NSColor colorWithCalibratedWhite:0.55 alpha:1.000];
}
- (NSColor *)yellowColor
{
	return [NSColor colorWithCalibratedWhite:0.7 alpha:1.000];
}
- (NSColor *)greenColor
{
	return [NSColor colorWithCalibratedWhite:0.79 alpha:1.000];
}

- (void)drawBackgroundWithFrame:(NSRect)cellFrame
{
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellFrame];
	[[NSColor colorWithCalibratedWhite:0.632 alpha:1.000] set];
	[path fill];
}
- (void)drawFuelInteriorWithFrame:(NSRect)cellFrame
{
	NSRect cellRect;
	cellRect.origin = NSZeroPoint;
	cellRect.size.height = cellFrame.size.height;
	cellRect.size.width = (cellFrame.size.width - numberOfCell - 1) / numberOfCell;
	
	cellRect.size.height = (cellRect.size.height - 3) / 2;
	cellRect.origin.y = cellRect.size.height + 2;
	
	for(NSInteger i = 0; i < self.numberOfFuelColoredCell; i++) {
		cellRect.origin.x = 1 + i + cellRect.size.width * i;
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellRect];
		
		[self.fuelStatusColor set];
		[path fill];
	}
	for(NSInteger i = self.numberOfFuelColoredCell; i < 10; i++) {
		cellRect.origin.x = 1 + i + cellRect.size.width * i;
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellRect];
		
		[[NSColor colorWithCalibratedWhite:0.948 alpha:1.000] set];
		[path fill];
	}
}
- (void)drawBullInteriorWithFrame:(NSRect)cellFrame
{
	NSRect cellRect;
	cellRect.origin = NSZeroPoint;
	cellRect.size.height = cellFrame.size.height;
	cellRect.size.width = (cellFrame.size.width - numberOfCell - 1) / numberOfCell;
	
	cellRect.size.height = (cellRect.size.height - 3) / 2;
	cellRect.origin.y = 1;
	
	for(NSInteger i = 0; i < self.numberOgBullColoredCell; i++) {
		cellRect.origin.x = 1 + i + cellRect.size.width * i;
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellRect];
		
		[self.bullStatusColor set];
		[path fill];
	}
	for(NSInteger i = self.numberOgBullColoredCell; i < 10; i++) {
		cellRect.origin.x = 1 + i + cellRect.size.width * i;
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellRect];
		
		[[NSColor colorWithCalibratedWhite:0.948 alpha:1.000] set];
		[path fill];
	}
}
const NSInteger numberOfCell = 10;

- (NSColor *)statusColorWithValue:(NSNumber *)value maxValue:(NSNumber *)maxValue
{
	NSColor *color = self.greenColor;
	
	switch([self numberOfColoredCellWithValue:value maxValue:maxValue]) {
		case 1:
		case 2:
		case 3:
			color = self.redColor;
			break;
		case 4:
		case 5:
		case 6:
		case 7:
			color = self.orangeColor;
			break;
		case 8:
		case 9:
			color = self.yellowColor;
			break;
	}
	return color;
}
- (NSInteger)numberOfColoredCellWithValue:(NSNumber *)value maxValue:(NSNumber *)maxValue
{
	if(!value || [value isEqual:[NSNull null]]) return 0;
	
	CGFloat maxFuel = [maxValue integerValue];
	CGFloat fuel = [value integerValue];
	if(fuel >= maxFuel) return 10;
	
	CGFloat result = ceil(fuel / maxFuel * numberOfCell);
	if(result > 9) return 9;
	return result;
}

- (NSInteger)numberOfFuelColoredCell
{
	return [self numberOfColoredCellWithValue:self.shipStatus.fuel maxValue:self.shipStatus.maxFuel];
}
- (NSColor *)fuelStatusColor
{
	return [self statusColorWithValue:self.shipStatus.fuel maxValue:self.shipStatus.maxFuel];
}
- (NSInteger)numberOgBullColoredCell
{
	return [self numberOfColoredCellWithValue:self.shipStatus.bull maxValue:self.shipStatus.maxBull];
}
- (NSColor *)bullStatusColor
{
	return [self statusColorWithValue:self.shipStatus.bull maxValue:self.shipStatus.maxBull];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawBackgroundWithFrame:cellFrame];
	[self drawFuelInteriorWithFrame:cellFrame];
	[self drawBullInteriorWithFrame:cellFrame];
}
@end
