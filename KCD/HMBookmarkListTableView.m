//
//  HMBookmarkListTableView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/31.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkListTableView.h"

@interface HMBookmarkListTableView () <NSMenuDelegate>
@property NSInteger contextMenuRow;
@end

@implementation HMBookmarkListTableView

- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self) {
		_contextMenuRow = -1;
	}
	return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if(self) {
		_contextMenuRow = -1;
	}
	return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
	if(self.contextMenuRow == -1) return;
	
	NSRect rowRect = [self rectOfRow:self.contextMenuRow];
	NSColor *color = [NSColor alternateSelectedControlColor];
	[color set];
	NSBezierPath *roundRect = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rowRect, 1, 1)
															  xRadius:4.0
															  yRadius:4.0];
	roundRect.lineWidth = 2;
	roundRect.lineCapStyle = NSRoundLineCapStyle;
	roundRect.lineJoinStyle = NSRoundLineJoinStyle;
	[roundRect stroke];
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
	if(!self.dataSource || ![self.dataSource respondsToSelector:@selector(tableView:menuForEvent:)]) return nil;
	
	NSMenu *menu = [(id<HMBookmarkListTableViewDatasorce>)self.dataSource tableView:self menuForEvent:event];
	if(menu) {
		NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
		self.contextMenuRow = [self rowAtPoint:mouse];
		NSRect rowRect= [self rectOfRow:self.contextMenuRow];
		[self setNeedsDisplayInRect:rowRect];
		[self displayIfNeeded];
		[menu setDelegate:self];
		
	}
	return menu;
}
- (void)menuDidClose:(NSMenu *)menu
{
	NSRect rowRect = [self rectOfRow:self.contextMenuRow];
	[self setNeedsDisplayInRect:rowRect];
	[menu setDelegate:nil];
	
	self.contextMenuRow = -1;
}
@end
