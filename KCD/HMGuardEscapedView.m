//
//  HMGuardEscapedView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/10.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMGuardEscapedView.h"


static NSString *taiString = nil;
static NSString *hiString = nil;

@implementation HMGuardEscapedView

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *path  = [mainBundle pathForResource:@"Taihi" ofType:@"txt"];
		NSError *error = nil;
		NSString *taihiString = [[NSString alloc] initWithContentsOfFile:path
																encoding:NSUTF8StringEncoding
																   error:&error];
		if(!taihiString) {
			if(error) {
				NSLog(@"Could not find Taihi.txt. Error -> %@", error);
				NSBeep();
				return;
			}
			NSLog(@"Could not find Taihi.txt");
			NSBeep();
			return;
		}
		
		if(taihiString.length != 2) {
			NSLog(@"Taihi.txt length is not two.");
			NSBeep();
			return;
		}
		taiString = [taihiString substringToIndex:1];
		hiString = [taihiString substringFromIndex:1];
	});
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	
	NSRect bounds = self.bounds;
	
	NSBezierPath *fillPath = [NSBezierPath bezierPathWithRect:bounds];
	[[NSColor colorWithCalibratedWhite:0.9 alpha:0.8] set];
	[fillPath fill];
	
	[self drawTaihiInrect:bounds];
}

- (void)drawTaihiInrect:(NSRect)bounds
{
	
	NSAffineTransform *rotate = [NSAffineTransform transform];
	[rotate translateXBy:0.0 yBy:65.0];
	[rotate rotateByDegrees:-27];
	[rotate concat];
	
	const CGFloat width = 50;
	const CGFloat height = 100;
	NSRect rect = NSMakeRect(
							 (NSInteger)((bounds.size.width - width) * 0.5),
							 (NSInteger)((bounds.size.height - height) * 0.5),
							 width, height);
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
	
	[[NSColor whiteColor] set];
	[path fill];
	
	[[NSColor blackColor] set];
	[path stroke];
	
	rect = NSInsetRect(rect, 3, 3);
	path = [NSBezierPath bezierPathWithRect:rect];
	path.lineWidth = 2;
	[path stroke];
	
	NSDictionary *taiAttr = @{
							  NSForegroundColorAttributeName : [NSColor lightGrayColor],
							  NSFontAttributeName : [NSFont boldSystemFontOfSize:width - 10],
							  };
	NSAttributedString *tai = [[NSAttributedString alloc] initWithString:taiString attributes:taiAttr];
	
	NSAttributedString *hi = [[NSAttributedString alloc] initWithString:hiString attributes:taiAttr];
	
	rect = NSInsetRect(rect, 2, 2);
	rect.origin.y += 4;
	rect.size.height -= 2;
	[tai drawInRect:rect];
	rect.size.height *= 0.5;
	[hi drawInRect:rect];
}

@end
