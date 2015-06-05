//
//  HMSourceListColoredView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/04.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMSourceListColoredView.h"

@interface HMSourceListColoredView ()
@property (strong, nonatomic) NSColor *backgroundColor;
@property (nonatomic, getter=isObservingKeyState) BOOL observingKeyState;
@end

@implementation HMSourceListColoredView
- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if([NSVisualEffectView class]) {
		NSVisualEffectView *view = [[NSVisualEffectView alloc] initWithFrame:self.frame];
		return (HMSourceListColoredView *)view;
	}
	return self;
}
- (void)dealloc
{
	if (self.isObservingKeyState) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSWindowDidBecomeKeyNotification
													  object:[self window]];
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSWindowDidResignKeyNotification
													  object:[self window]];
	}
}

- (void)viewDidMoveToWindow
{
	NSTableView *tableView = [[NSTableView alloc] init];
	[tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	_backgroundColor = [tableView backgroundColor];
	[self addWindowKeyStateObservers];
}

- (void)addWindowKeyStateObservers
{
	if (!self.isObservingKeyState) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(redisplay)
													 name:NSWindowDidBecomeKeyNotification
												   object:[self window]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(redisplay)
													 name:NSWindowDidResignKeyNotification
												   object:[self window]];
	}
	self.observingKeyState = YES;
}

- (void)redisplay
{
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[_backgroundColor setFill];
	NSRectFill(dirtyRect);
}

@end
