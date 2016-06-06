//
//  HMImageView.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/05/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMImageView.h"

@interface HMImageView ()
@property (nonatomic, strong) NSShadow *imageShadow;
@end

@implementation HMImageView

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect bounds = self.bounds;
	
	[[NSColor controlBackgroundColor] set];
	[NSBezierPath fillRect:bounds];
	
	[[NSColor blackColor] set];
	[NSBezierPath setDefaultLineWidth:1.0];
	[NSBezierPath strokeRect:bounds];
	
	[NSBezierPath clipRect:NSInsetRect(bounds, 1, 1)];
    // Drawing code here.
	
	[self.imageShadow set];
	
	NSUInteger count = self.images.count;
	
	const CGFloat alphaFactor = 0.7;
	CGFloat alpha = pow(alphaFactor, count - 1);
	
	CGFloat offset = bounds.size.width * 0.1 / 2 / 3;
	CGFloat border = offset * 3;
	NSRect rect = NSInsetRect(bounds, border, border);
	
	rect = NSOffsetRect(rect, offset * (count - 1), offset * (count - 1));
	
	for(NSImage *image in [self.images reverseObjectEnumerator]) {
		NSSize size = image.size;
		NSSize frameSize = rect.size;
		CGFloat ratio = 1;
		CGFloat ratioX, ratioY;
		
		ratioX = frameSize.height / size.height;
		ratioY = frameSize.width / size.width;
		if(ratioX > ratioY) {
			ratio = ratioY;
		} else {
			ratio = ratioX;
		}
		
		NSSize drawSize = NSMakeSize(size.width * ratio, size.height * ratio);
		NSRect drawRect = NSMakeRect(rect.origin.x + (frameSize.width - drawSize.width) / 2,
									 rect.origin.y + (frameSize.height - drawSize.height) / 2,
									 drawSize.width,
									 drawSize.height);
		[image drawInRect:drawRect
				 fromRect:NSZeroRect
				operation:NSCompositeSourceOver
				 fraction:alpha];
		
		rect = NSOffsetRect(rect, offset * -1, offset * -1);
		alpha /= alphaFactor;
	}
}


- (NSRect)imageRect
{
	if(self.images.count == 0) return NSZeroRect;
	
	NSRect bounds = self.bounds;
	
	CGFloat offset = bounds.size.width * 0.1 / 2 / 3;
	CGFloat border = offset * 3;
	NSRect rect = NSInsetRect(bounds, border, border);
	
	NSSize size = self.images[0].size;
	NSSize frameSize = rect.size;
	CGFloat ratio = 1;
	CGFloat ratioX, ratioY;
	
	ratioX = frameSize.height / size.height;
	ratioY = frameSize.width / size.width;
	if(ratioX > ratioY) {
		ratio = ratioY;
	} else {
		ratio = ratioX;
	}
	NSSize drawSize = NSMakeSize(size.width * ratio, size.height * ratio);
	NSRect drawRect = NSMakeRect(rect.origin.x + (frameSize.width - drawSize.width) / 2,
								 rect.origin.y + (frameSize.height - drawSize.height) / 2,
								 drawSize.width,
								 drawSize.height);
	
	return drawRect;
}

- (NSShadow *)imageShadow
{
	if(_imageShadow) return _imageShadow;
	
	_imageShadow = [NSShadow new];
	_imageShadow.shadowOffset = NSMakeSize(2, -2);
	_imageShadow.shadowBlurRadius = 4;
	_imageShadow.shadowColor = [NSColor darkGrayColor];
	
	return _imageShadow;
}

- (void)setImages:(NSArray<NSImage *> *)images
{
	_images = images;
	self.needsDisplay = YES;
}

@end
