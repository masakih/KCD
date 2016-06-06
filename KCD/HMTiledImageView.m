//
//  HMTiledImageView.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/05/02.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMTiledImageView.h"

@interface HMTitledImageCellInformation : NSObject
@property NSRect frame;
@end

@implementation HMTitledImageCellInformation
@end


static NSString *privateDraggingUTI = @"com.masakih.KCD.ScreenshotDDImte";

@interface HMTiledImageView () <NSDraggingSource>
@property (copy, nonatomic) NSArray<HMTitledImageCellInformation *> *infos;
@property (weak, nonatomic) HMTitledImageCellInformation *currentSelection;

@property (nonatomic, strong) NSImageCell *imageCell;
@end

@implementation HMTiledImageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if(self) {
		[self registerForDraggedTypes:@[privateDraggingUTI]];
		
		_columnCount = 2;
		
		_imageCell = [[NSImageCell alloc] initImageCell:nil];
		_imageCell.imageAlignment = NSImageAlignCenter;
		_imageCell.imageScaling = NSImageScaleProportionallyDown;
	}
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor controlBackgroundColor] set];
	[NSBezierPath fillRect:self.bounds];
	
	[[NSColor blackColor] set];
	[NSBezierPath setDefaultLineWidth:1.0];
	[NSBezierPath strokeRect:self.bounds];
	
	[NSBezierPath clipRect:NSInsetRect(self.bounds, 1, 1)];
	
//	[super drawRect:dirtyRect];
	NSRect cellRect = NSInsetRect(self.bounds, 1, 1);
	[self.imageCell drawWithFrame:cellRect inView:self];
	[self.imageCell drawInteriorWithFrame:cellRect inView:self];
	
	if(self.currentSelection) {
		NSRect rect = self.currentSelection.frame;
		rect = NSInsetRect(rect, 1, 1);
		
		[[NSColor keyboardFocusIndicatorColor] set];
		[NSBezierPath setDefaultLineWidth:2];
		[NSBezierPath strokeRect:rect];
	}
}
- (void)setColumnCount:(NSInteger)columnCount
{
	_columnCount = columnCount;
	self.images = _images;
}

- (void)setImages:(NSArray<NSImage *> *)images
{
	_images = images;
	
	NSUInteger imageCount = self.images.count;
	
	if(imageCount == 0) {
		self.imageCell.image = nil;
		self.needsDisplay = YES;
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create("makeTrimedImage queue", DISPATCH_QUEUE_SERIAL);
	dispatch_async(queue, ^{
		NSMutableArray<HMTitledImageCellInformation *> *infos = [NSMutableArray array];
		
		NSUInteger imageCount = images.count;
		
		if(imageCount == 0) {
			return;
		}
		
		NSSize size = images[0].size;
		
		NSInteger col = imageCount < self.columnCount ? imageCount : self.columnCount;
		NSInteger row = imageCount / self.columnCount + (imageCount % self.columnCount ? 1 : 0);
		
		NSImage *trimedImage = [[NSImage alloc] initWithSize:NSMakeSize(size.width * col, size.height * row)];
		
		// 空き枠に市松模様を描画
		if(imageCount % self.columnCount < self.columnCount) {
			[trimedImage lockFocus];
			{
				[[NSColor whiteColor] setFill];
				NSRectFill(NSMakeRect(0, 0, size.width * col, size.height * row));
				
				[[NSColor lightGrayColor] setFill];
				// 市松模様のサイズ
				const NSInteger tileSize = 10;
				for(NSInteger i = 0; i < (size.width * col) / tileSize; i++) {
					for(NSInteger j = 0; j < (size.height * row) / tileSize; j++) {
						if(i % 2 == 0 && j % 2 == 1) continue;
						if(i % 2 == 1 && j % 2 == 0) continue;
						NSRect rect = NSMakeRect(i * tileSize, j * tileSize, tileSize, tileSize);
						NSRectFill(rect);
					}
				}
			}
			[trimedImage unlockFocus];
		}
		
		// 画像の描画
		[images enumerateObjectsUsingBlock:^(NSImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			CGFloat x = (idx % self.columnCount ) * size.width;
			CGFloat y = size.height * row - (idx / self.columnCount + 1) * size.height;
			[trimedImage lockFocus];
			{
				[obj drawAtPoint:NSMakePoint(x, y)
						fromRect:NSMakeRect(0.0, 0.0, size.width, size.height)
					   operation:NSCompositeCopy
						fraction:1.0];
			}
			[trimedImage unlockFocus];
			
			HMTitledImageCellInformation *info = [HMTitledImageCellInformation new];
			info.frame = NSMakeRect(x, y, size.width, size.height);
			[infos addObject:info];
		}];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.imageCell.image = trimedImage;
			self.needsDisplay = YES;
			self.infos = infos;
		});
	});
}

- (NSImage *)image
{
	return self.imageCell.image;
}

- (void)removeAllTrackingAreas
{
	NSArray *array = self.trackingAreas;
	for(NSTrackingArea *area in array) {
		[self removeTrackingArea:area];
	}
}

- (void)resetTrackingArea
{
	if(self.infos.count > 2) {
		[self.infos enumerateObjectsUsingBlock:^(HMTitledImageCellInformation * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
			NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:info.frame
																options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow
																  owner:self
															   userInfo:@{ @"info" : info }];
			
			[self addTrackingArea:area];
		}];
	}
}

- (NSArray<HMTitledImageCellInformation *> *)recalcTrackingAreaFrame:(NSArray<HMTitledImageCellInformation *> *)infos
{
	NSSize size = self.imageCell.image.size;
	NSSize frameSize = self.frame.size;
	CGFloat ratio = 1;
	CGFloat ratioX, ratioY;
	NSSize offset;
	
	ratioX = frameSize.height / size.height;
	ratioY = frameSize.width / size.width;
	if(ratioX > 1 && ratioY > 1) {
		offset.width = (frameSize.width - size.width) / 2;
		offset.height = (frameSize.height - size.height) / 2;
	} else if(ratioX > ratioY) {
		ratio = ratioY;
		offset.width = 0;
		offset.height = (frameSize.height - size.height * ratio) / 2;
	} else {
		ratio = ratioX;
		offset.width = (frameSize.width - size.width * ratio) / 2;
		offset.height = 0;
	}
	
	NSMutableArray<HMTitledImageCellInformation *> *newInfos = [NSMutableArray array];
	
	[infos enumerateObjectsUsingBlock:^(HMTitledImageCellInformation * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
		NSRect trackRect = NSMakeRect(info.frame.origin.x * ratio + offset.width,
									  info.frame.origin.y * ratio + offset.height,
									  info.frame.size.width * ratio,
									  info.frame.size.height * ratio);
		HMTitledImageCellInformation *newInfo = [HMTitledImageCellInformation new];
		newInfo.frame = trackRect;
		[newInfos addObject:newInfo];
	}];
	
	return newInfos;
}


- (void)setInfos:(NSArray<HMTitledImageCellInformation *> *)infos
{
	if(self.inLiveResize) return;
	
	[self removeAllTrackingAreas];
	
	if(infos.count < 2) {
		self.currentSelection = nil;
		_infos = infos;
		return;
	}
	
	_infos = [self recalcTrackingAreaFrame:infos];
	
	[self resetTrackingArea];
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	
	self.images = _images;
}
- (void)viewWillStartLiveResize
{
	// ゴミイベントを拾うため一時的にトラッキングを解除
	[self removeAllTrackingAreas];
}
- (void)viewDidEndLiveResize
{
	self.images = _images;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	NSTrackingArea *area = theEvent.trackingArea;
	NSDictionary *info = area.userInfo;
	if(!info) return;
	
	self.currentSelection = info[@"info"];
	self.needsDisplay = YES;
	
}
- (void)mouseExited:(NSEvent *)theEvent
{
	self.currentSelection = nil;
	self.needsDisplay = YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint mouseInWindow = theEvent.locationInWindow;
	NSPoint mouse = [self convertPoint:mouseInWindow fromView:nil];
	
	[self.infos enumerateObjectsUsingBlock:^(HMTitledImageCellInformation * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if(NSMouseInRect(mouse, info.frame, self.flipped)) {
			
			NSPasteboardItem *pasteboardItem = [NSPasteboardItem new];
			[pasteboardItem setPropertyList:@(idx) forType:privateDraggingUTI];
			
			NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:pasteboardItem];
			[item setDraggingFrame:info.frame contents:self.images[idx]];
			
			NSDraggingSession *session = [self beginDraggingSessionWithItems:@[item]
																	   event:theEvent
																	  source:self];
			session.animatesToStartingPositionsOnCancelOrFail = YES;
			session.draggingFormation = NSDraggingFormationNone;
		}
	}];
	
	// ドラッグ中の全てのmouseEnterイベントがドラッグ後に一気にくるため一時的にTrackingを無効化
	[self removeAllTrackingAreas];
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	if(context == NSDraggingContextWithinApplication) {
		return NSDragOperationMove;
	}
	
	return NSDragOperationNone;
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return [self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	if(![sender.draggingPasteboard.types containsObject:privateDraggingUTI]) return NSDragOperationNone;
	
	if([sender draggingSourceOperationMask] & NSDragOperationMove) {
		NSPoint mouse = [self convertPoint:sender.draggingLocation fromView:nil];
		__block BOOL handled = NO;
		[self.infos enumerateObjectsUsingBlock:^(HMTitledImageCellInformation * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
			if(NSMouseInRect(mouse, info.frame, self.flipped)) {
				handled = YES;
				if([self.currentSelection isEqual:info]) return;
				
				self.currentSelection = info;
				self.needsDisplay = YES;
			}
		}];
		if(!handled) {
			self.currentSelection = nil;
			self.needsDisplay = YES;
		}
		return NSDragOperationMove;
	}
	
	return NSDragOperationNone;
}

- (void)draggingExited:(nullable id <NSDraggingInfo>)sender
{
	self.currentSelection = nil;
	self.needsDisplay = YES;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	if(![sender.draggingPasteboard.types containsObject:privateDraggingUTI]) return NO;
	
	self.currentSelection = nil;
	self.needsDisplay = YES;
	
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	if(![sender.draggingPasteboard.types containsObject:privateDraggingUTI]) return NO;
	
	NSPasteboard *pboard = sender.draggingPasteboard;
	if(pboard.pasteboardItems.count == 0) return NO;
	
	NSPasteboardItem * item = pboard.pasteboardItems[0];
	NSInteger sourceIndex = [[item propertyListForType:privateDraggingUTI] integerValue];
	
	if(sourceIndex > self.images.count) return NO;
	
	__block NSInteger targetIndex = NSNotFound;
	NSPoint mouse = [self convertPoint:sender.draggingLocation fromView:nil];
	[self.infos enumerateObjectsUsingBlock:^(HMTitledImageCellInformation * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
		if(NSMouseInRect(mouse, info.frame, self.flipped)) {
			targetIndex = idx;
		}
	}];
	if(targetIndex == NSNotFound) return NO;
	
	NSMutableArray *newImages = [self.images mutableCopy];
	NSImage *sourceImage = self.images[sourceIndex];
	[newImages removeObject:sourceImage];
	[newImages insertObject:sourceImage atIndex:targetIndex];
	
	self.images = newImages;
	
	return YES;
}

- (void)draggingEnded:(nullable id <NSDraggingInfo>)sender
{
	[self resetTrackingArea];
}


@end
