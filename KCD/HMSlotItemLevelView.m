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


static CGImageRef sMaskImage = nil;

@interface HMSlotItemLevelView ()

@property (strong) NSObjectController *slotItemController;

@property (nonatomic, strong) NSNumber *slotItemLevel;
@property (nonatomic, strong) NSNumber *slotItemAlv;

@end

@implementation HMSlotItemLevelView

- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self) {
		_slotItemController = [NSObjectController new];
		[self bind:@"slotItemLevel"
		  toObject:_slotItemController
	   withKeyPath:@"selection.level"
		   options:nil];
		[self bind:@"slotItemAlv"
		  toObject:_slotItemController
	   withKeyPath:@"selection.alv"
		   options:nil];
	}
	return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if(self) {
		_slotItemController = [NSObjectController new];
		[self bind:@"slotItemLevel"
		  toObject:_slotItemController
	   withKeyPath:@"content.level"
		   options:nil];
		[self bind:@"slotItemAlv"
		  toObject:_slotItemController
	   withKeyPath:@"content.alv"
		   options:nil];
	}
	return self;
}
- (void)dealloc
{
	[self unbind:@"slotItemLevel"];
	[self unbind:@"slotItemAlv"];
}


- (CGImageRef)maskImage
{
	if(sMaskImage) return sMaskImage;
	
	NSRect rect = self.bounds;
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
	CGContextRef maskContext =
	CGBitmapContextCreate(
						  NULL,
						  rect.size.width,
						  rect.size.height,
						  8,
						  rect.size.width,
						  colorspace,
						  0);
	CGColorSpaceRelease(colorspace);
	
	// Switch to the context for drawing
	NSGraphicsContext *maskGraphicsContext =
	[NSGraphicsContext graphicsContextWithGraphicsPort:maskContext
											   flipped:NO];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:maskGraphicsContext];
	
	// Draw the text right-way-up (non-flipped context)
	
	NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:
							[NSColor whiteColor], 0.0,
							[NSColor whiteColor], 0.75,
							[NSColor blackColor], 0.85,
							[NSColor blackColor], 1.0,
							nil];
	
	[gradient drawInRect:rect angle:0.0];
	// Switch back to the window's context
	[NSGraphicsContext restoreGraphicsState];
	
	// Create an image mask from what we've drawn so far
	sMaskImage = CGBitmapContextCreateImage(maskContext);
	
	return sMaskImage;
}

- (BOOL)useMask
{
	NSNumber *level = self.slotItemLevel;
	if(!level || [level isKindOfClass:[NSNull class]]) return NO;
	if(level.integerValue == 0) return NO;
	
	return YES;
}
- (void)drawRect:(NSRect)dirtyRect {
	
	BOOL useMask = self.useMask;
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(context);
	
	if(useMask) {
		CGContextClipToMask(context, NSRectToCGRect(self.bounds), self.maskImage);
	}
	
	[super drawRect:dirtyRect];
	
	CGContextRestoreGState(context);
	
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
	NSRect rect = self.bounds;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset, rect.size.height)];
	path.lineWidth = 1;
	
	return path;
}
- (NSBezierPath *)levelTwoBezierPath
{
	NSRect rect = self.bounds;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset, rect.size.height)];
	
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.padding, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - self.padding, rect.size.height)];
	
	path.lineWidth = 1;
	
	return path;
}
- (NSBezierPath *)levelThreeBezierPath
{
	NSRect rect = self.bounds;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset, rect.size.height)];
	
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.padding, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - self.padding, rect.size.height)];
	
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.padding * 2, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - self.padding * 2, rect.size.height)];
	
	path.lineWidth = 1;
	
	return path;
}
- (NSBezierPath *)levelFourBezierPath
{
	NSRect rect = self.bounds;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.slideOffset, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset, rect.size.height)];
	
	path.lineWidth = 2;
	
	return path;
}
- (NSBezierPath *)levelFiveBezierPath
{
	NSRect rect = self.bounds;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.slideOffset, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset, rect.size.height)];
	
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.slideOffset - self.padding, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - self.padding, rect.size.height)];
	
	path.lineWidth = 2;
	
	return path;
}
- (NSBezierPath *)levelSixBezierPath
{
	NSRect rect = self.bounds;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.slideOffset, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset, rect.size.height)];
	
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.slideOffset - self.padding, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - self.padding, rect.size.height)];
	
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - self.slideOffset - self.padding * 2, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - self.padding * 2, rect.size.height)];
	
	path.lineWidth = 2;
	
	return path;
}
- (NSBezierPath *)levelSevenBezierPath
{
	const CGFloat anglePoint = 4.0;
	NSRect rect = self.bounds;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - anglePoint, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset, rect.size.height * 0.5)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - anglePoint, rect.size.height)];
	
	[path moveToPoint:NSMakePoint(rect.size.width - self.offset - anglePoint - self.padding, 0)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - self.padding, rect.size.height * 0.5)];
	[path lineToPoint:NSMakePoint(rect.size.width - self.offset - anglePoint - self.padding, rect.size.height)];
	
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
			return [NSColor colorWithCalibratedRed:0.257 green:0.523 blue:0.643 alpha:1.000];
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
			shadow.shadowColor = [NSColor colorWithCalibratedRed:0.095 green:0.364 blue:0.917 alpha:1.000];
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

- (void)setSlotItemLevel:(NSNumber *)slotItemLevel
{
	_slotItemLevel = slotItemLevel;
	self.needsDisplay = YES;
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
	
	NSDictionary *attr = @{
						   NSFontAttributeName : font,
						   NSForegroundColorAttributeName : [self levelColor],
						   };
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
																	 attributes:attr];
	NSRect boundingRect = [attrString boundingRectWithSize:self.frame.size options:0];
	NSRect rect = self.frame;
	rect.origin.x = rect.size.width - boundingRect.size.width - 1.0;
	rect.origin.y = 0;
	
	[attrString drawInRect:rect];
}

- (void)setSlotItemAlv:(NSNumber *)slotItemAlv
{
	_slotItemAlv = slotItemAlv;
	self.needsDisplay = YES;
}

#pragma mark - property

- (void)fetchSlotItem
{
	self.slotItemController.content =  nil;
	
	if(!self.slotItemID || [self.slotItemID isEqual:@(-1)]) {
		return;
	}
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"SlotItem"
											error:&error
								  predicateFormat:@"id = %@", self.slotItemID];
	if(error) {
		NSLog(@"SlotItem is invalid -> %@", error);
		return;
	}
	if(array.count == 0) {
		NSLog(@"Can not find slotItem for %@", self.slotItemID);
		return;
	}
	
	self.slotItemController.content = array[0];
}
- (void)setSlotItemID:(NSNumber *)slotItemID
{
	if([self.slotItemID isEqual:slotItemID]) return;
	_slotItemID = slotItemID;
	[self fetchSlotItem];
	self.needsDisplay = YES;
}

@end
