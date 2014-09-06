//
//  HMMaskSelectView.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/05.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMaskSelectView.h"

#import "HMMaskInfomation.h"


const NSInteger kNumberOfMask = 4;
static NSRect maskRects[kNumberOfMask];



@implementation HMMaskSelectView

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		maskRects[0] = NSMakeRect(113, 455, 100, 18);
		maskRects[1] = NSMakeRect(203, 330, 200, 25);
		maskRects[2] = NSMakeRect(95, 378, 100, 18);
		maskRects[3] = NSMakeRect(60, 378, 100, 18);
	});
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
		[self buildMask];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self) {
		[self buildMask];
	}
	return self;
}

- (void)buildMask
{
	self.masks = [NSMutableArray new];
	for(NSInteger i = 0; i < kNumberOfMask; i++ ) {
		HMMaskInfomation *info = [HMMaskInfomation new];
		info.maskRect = maskRects[i];
		[self.masks addObject:info];
		if(i == 3) {
			info.borderColor = [NSColor colorWithCalibratedRed:0.000 green:0.011 blue:1.000 alpha:1.000];
		} else {
			info.borderColor = [NSColor redColor];
		}
		info.maskColor = [NSColor blackColor];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	[context setShouldAntialias:NO];
	
	CGFloat dashSeed[] = {3.0, 3.0};
	for(HMMaskInfomation *info in self.masks) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:info.maskRect];
		if(info.enable) {
			[info.maskColor set];
			[path fill];
		}
		[path setLineDash:dashSeed count:2 phase:0];
		[info.borderColor set];
		[path stroke];
		[path setLineDash:dashSeed count:2 phase:3.0];
		[[NSColor lightGrayColor] set];
		[path stroke];
	}
	
	[context restoreGraphicsState];
	
#if 0
	NSBezierPath *path = [NSBezierPath bezierPath];
	for(int i = 0; i < 800; i += 50) {
		[path moveToPoint:NSMakePoint(i, 0)];
		[path lineToPoint:NSMakePoint(i, 480)];
	}
	for(int j = 0; j < 480; j += 50) {
		[path moveToPoint:NSMakePoint(0, j)];
		[path lineToPoint:NSMakePoint(800, j)];
	}
	[[NSColor whiteColor] set];
	[path stroke];
#endif
}

- (void)mouseUp:(NSEvent *)event
{
	NSPoint mouse = [event locationInWindow];
	mouse = [self convertPoint:mouse fromView:nil];
	
	for(HMMaskInfomation *info in [self.masks reverseObjectEnumerator]) {
		if(NSMouseInRect(mouse, info.maskRect, self.isFlipped)) {
			info.enable = !info.enable;
			[self setNeedsDisplayInRect:NSInsetRect(info.maskRect, -5, -5)];
			break;
		}
	}
}

- (IBAction)disableAllMasks:(id)sender
{
	for(HMMaskInfomation *info in self.masks) {
		info.enable = NO;
	}
	[self setNeedsDisplay:YES];
}

@end
