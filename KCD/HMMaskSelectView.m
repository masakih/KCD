//
//  HMMaskSelectView.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/05.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMaskSelectView.h"

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
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	[context setShouldAntialias:NO];
	
	[[NSColor redColor] set];
	CGFloat dashSeed[] = {3.0, 3.0};
	for(int i = 0; i < kNumberOfMask; i++) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:maskRects[i]];
		[path setLineDash:dashSeed count:2 phase:0];
		[path stroke];
	}
	
	[context restoreGraphicsState];
	
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
}

- (void)mouseUp:(NSEvent *)event
{
	NSPoint mouse = [event locationInWindow];
	mouse = [self convertPoint:mouse fromView:nil];
	
	for(NSInteger i = 0; i < kNumberOfMask; i++ ) {
		if(NSMouseInRect(mouse, maskRects[i], self.isFlipped)) {
			NSLog(@"Click on Mask view.");
			break;
		}
	}
}

@end
