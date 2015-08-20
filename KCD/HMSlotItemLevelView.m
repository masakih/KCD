//
//  HMSlotItemLevelView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/16.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMSlotItemLevelView.h"

#import "HMServerDataStore.h"
#import "HMKCSlotItemObject+Extensions.h"

#import "HMPortNotifyCommand.h"


static NSColor *sContentColor = nil;

@interface HMSlotItemLevelView ()

@property (strong) HMKCSlotItemObject *slotItem;

@end

@implementation HMSlotItemLevelView

- (void)dealloc
{
	[self.slotItem removeObserver:self forKeyPath:@"level"];
	[self.slotItem removeObserver:self forKeyPath:@"alv"];
}

- (void)awakeFromNib
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(didAlivalPort:)
			   name:@"HMPortAPIRecieveNotification"
			 object:nil];
}

- (void)calcContentColor
{
	NSRect rect = NSMakeRect(1, 1, 2, 2);
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
	sContentColor = [rep colorAtX:1 y:1];
}
- (void)drawRect:(NSRect)dirtyRect {
	
	[super drawRect:dirtyRect];
	
	if(!sContentColor) [self calcContentColor];
	
	if(!self.slotItemID) return;
	if(self.slotItemID.integerValue == 0) return;
	if(self.slotItemID.integerValue == -1) return;
	
	NSNumber *aLevel = [self slotItemAlv];
	if([aLevel isKindOfClass:[NSNumber class]]) {
		[[self colorForALevel:aLevel] set];
		[[self shadowForALevel:aLevel] set];
		[[self bezierPathForALevel:aLevel] stroke];
	} else {
		[self drawLevel];
	}
}

- (void)didAlivalPort:(NSNotification *)notification
{
	self.needsDisplay = YES;
}

#pragma mark - Air Level

- (CGFloat)offset
{
	return 4;
}
- (CGFloat)padding
{
	return 4.0;
}
- (CGFloat)slideOffset
{
	return 3.5;
}
- (NSBezierPath *)levelOneBezierPath
{
	NSRect frame = NSInsetRect(self.frame, 0, 1);
	frame.origin = NSZeroPoint;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset, frame.size.height)];
	path.lineWidth = 1;
	
	return path;
}
- (NSBezierPath *)levelTwoBezierPath
{
	NSRect frame = NSInsetRect(self.frame, 0, 1);
	frame.origin = NSZeroPoint;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset, frame.size.height)];
	
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - 3.0, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - 3.0, frame.size.height)];
	
	path.lineWidth = 1;
	
	return path;
}
- (NSBezierPath *)levelThreeBezierPath
{
	NSRect frame = NSInsetRect(self.frame, 0, 1);
	frame.origin = NSZeroPoint;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset, frame.size.height)];
	
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - 3.0, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - 3.0, frame.size.height)];
	
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - 3.0 * 2, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - 3.0 * 2, frame.size.height)];
	
	path.lineWidth = 1;
	
	return path;
}
- (NSBezierPath *)levelFourBezierPath
{
	NSRect frame = NSInsetRect(self.frame, 0, 1);
	frame.origin = NSZeroPoint;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - self.slideOffset, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset, frame.size.height)];
	
	path.lineWidth = 2;
	
	return path;
}
- (NSBezierPath *)levelFiveBezierPath
{
	NSRect frame = NSInsetRect(self.frame, 0, 1);
	frame.origin = NSZeroPoint;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - self.slideOffset, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset, frame.size.height)];
	
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - self.slideOffset - self.padding, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - self.padding, frame.size.height)];
	
	path.lineWidth = 2;
	
	return path;
}
- (NSBezierPath *)levelSixBezierPath
{
	NSRect frame = NSInsetRect(self.frame, 0, 1);
	frame.origin = NSZeroPoint;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - self.slideOffset, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset, frame.size.height)];
	
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - self.slideOffset - self.padding, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - self.padding, frame.size.height)];
	
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - self.slideOffset - self.padding * 2, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - self.padding * 2, frame.size.height)];
	
	path.lineWidth = 2;
	
	return path;
}
- (NSBezierPath *)levelSevenBezierPath
{
	NSRect frame = NSInsetRect(self.frame, 0, 1);
	frame.origin = NSZeroPoint;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - 4.0, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset, frame.size.height * 0.5)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - 4.0, frame.size.height)];
	
	[path moveToPoint:NSMakePoint(frame.size.width - self.offset - 4.0 - self.padding, 0)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - self.padding, frame.size.height * 0.5)];
	[path lineToPoint:NSMakePoint(frame.size.width - self.offset - 4.0 - self.padding, frame.size.height)];
	
	path.lineWidth = 2;
	
	return path;
}


- (NSBezierPath *)bezierPathForALevel:(NSNumber *)level
{
	NSBezierPath *path = nil;
	switch (level.integerValue) {
		case 0:
			return nil;
		case 1:
			path = [self levelOneBezierPath];
			break;
		case 2:
			path = [self levelTwoBezierPath];
			break;
		case 3:
			path = [self levelThreeBezierPath];
			break;
		case 4:
			path = [self levelFourBezierPath];
			break;
		case 5:
			path = [self levelFiveBezierPath];
			break;
		case 6:
			path = [self levelSixBezierPath];
			break;
		case 7:
			path = [self levelSevenBezierPath];
			break;
		default:
			return nil;
	}
	
	return path;
}

- (NSColor *)colorForALevel:(NSNumber *)level
{
	switch (level.integerValue) {
		case 0:
			return nil;
		case 1:
		case 2:
		case 3:
			return [NSColor colorWithCalibratedRed:0.332 green:0.543 blue:0.646 alpha:1.000];
		case 4:
		case 5:
		case 6:
		case 7:
			return [NSColor colorWithCalibratedRed:200/255.0 green:140/255.0 blue:0.000 alpha:1.000];
		default:
			return nil;
	}
	return nil;
}
- (NSShadow *)shadowForALevel:(NSNumber *)level
{
	NSShadow *shadow = [NSShadow new];
	switch (level.integerValue) {
		case 0:
			return nil;
		case 1:
		case 2:
		case 3:
			shadow.shadowColor = [NSColor colorWithCalibratedRed:0.152 green:0.501 blue:0.853 alpha:1.000];
			shadow.shadowBlurRadius = 4;
			break;
		case 4:
		case 5:
		case 6:
		case 7:
			shadow.shadowColor = [NSColor yellowColor];
			shadow.shadowBlurRadius = 3;
			break;
		default:
			return nil;
	}
	return shadow;
}

- (NSNumber *)slotItemAlv
{
	if(!self.slotItemID) return nil;
	
	if(!self.slotItem) {
		[self fetchSlotItem];
	}
	
	return self.slotItem.alv;
}


#pragma mark - Level

- (NSColor *)levelColor
{
	return [NSColor colorWithCalibratedRed:0.135 green:0.522 blue:0.619 alpha:1.000];
}
- (void)drawLevel
{
	NSNumber *level = self.slotItemLevel;
	if(!level || [level isKindOfClass:[NSNull class]]) return;
	if(level.integerValue == 0) return;
	
	NSString *string = [NSString stringWithFormat:@"★+%@", level];
	if(level.integerValue == 10) {
		string = @"max";
	}
	NSFont *font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
	
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
																	 attributes:@{
																				  NSFontAttributeName : font,
																				  NSForegroundColorAttributeName : [self levelColor],
																				  }
									  ];
	NSRect boundingRect = [attrString boundingRectWithSize:self.frame.size options:0];
	NSRect rect = self.frame;
	rect.origin.x = self.frame.size.width - boundingRect.size.width * 2;
	rect.origin.y = 0;
	rect.size.width = boundingRect.size.width * 2;
	
	
	NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:
							[NSColor colorWithCalibratedWhite:1 alpha:0.000], 0.0,
							sContentColor, 0.5,
							sContentColor, 1.0,
							nil];
	
	[gradient drawInRect:rect angle:0.0];
	
	rect = self.frame;
	rect.origin.x = self.frame.size.width - boundingRect.size.width - 1.0;
	rect.origin.y = 0;
	
	
	[attrString drawInRect:rect];
}

- (NSNumber *)slotItemLevel
{
	if(!self.slotItemID) return nil;
	
	if(!self.slotItem) {
		[self fetchSlotItem];
	}
	
	return self.slotItem.level;
}

#pragma mark - property

- (void)fetchSlotItem
{
	[self.slotItem removeObserver:self forKeyPath:@"level"];
	[self.slotItem removeObserver:self forKeyPath:@"alv"];
	
	if(!self.slotItemID || [self.slotItemID isEqual:@(-1)]) {
		self.slotItem = nil;
		return;
	}
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"SlotItem"
											error:&error
								  predicateFormat:@"id = %@", self.slotItemID];
	if(error) {
		NSLog(@"SlotItem is invalid -> %@", error);
		self.slotItem = nil;
		return;
	}
	if(array.count == 0) {
		NSLog(@"Can not find slotItem for %@", self.slotItemID);
		self.slotItem = nil;
		return;
	}
	
	self.slotItem = array[0];
	
	[self.slotItem addObserver:self forKeyPath:@"level" options:0 context:NULL];
	[self.slotItem addObserver:self forKeyPath:@"alv" options:0 context:NULL];
}
- (void)setSlotItemID:(NSNumber *)slotItemID
{
	if([self.slotItemID isEqual:slotItemID]) return;
	self.slotItem = nil;
	_slotItemID = slotItemID;
	[self fetchSlotItem];
	self.needsDisplay = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"level"] || [keyPath isEqualToString:@"alv"]) {
		self.needsDisplay = YES;
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
