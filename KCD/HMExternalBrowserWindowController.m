//
//  HMExternalBrowserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/11/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMExternalBrowserWindowController.h"

#import "HMAppDelegate.h"

@interface HMExternalBrowserWindowController ()
@property (nonatomic, weak) IBOutlet NSSegmentedControl *goSegment;
@end

@implementation HMExternalBrowserWindowController

@synthesize canResize = _canResize;
@synthesize canScroll = _canScroll;

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (void)awakeFromNib
{
//	[self goHome:nil];
	
	// for Maverick
	if(floor(NSAppKitVersionNumber) == NSAppKitVersionNumber10_9) {
		self.webView.layerUsesCoreImageFilters = YES;
	}
	
	[self.webView addObserver:self
				   forKeyPath:@"canGoBack"
					  options:0
					  context:(__bridge void *)(self.webView)];
	[self.webView addObserver:self
				   forKeyPath:@"canGoForward"
					  options:0
					  context:(__bridge void *)(self.webView)];
	
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	[self.webView setApplicationNameForUserAgent:appDelegate.appNameForUserAgent];
	
	self.canResize = YES;
	self.canScroll = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	id contextObject = (__bridge id)(context);
	if(self.webView == contextObject) {
		if([keyPath isEqualToString:@"canGoBack"]) {
			[self.goSegment setEnabled:self.webView.canGoBack forSegment:0];
		}
		if([keyPath isEqualToString:@"canGoForward"]) {
			[self.goSegment setEnabled:self.webView.canGoForward forSegment:1];
		}
		
		
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

static BOOL sameState(BOOL a, BOOL b) {
	if(a && b) {
		return YES;
	}
	if(!a && !b) {
		return YES;
	}
	return NO;
}
- (void)setCanResize:(BOOL)canResize
{
	if(sameState(_canResize, canResize)) return;
	
	_canResize = canResize;
	
	NSUInteger styleMaks = self.window.styleMask;
	if(canResize) {
		styleMaks |= NSResizableWindowMask;
	} else {
		styleMaks &= ~NSResizableWindowMask;
	}
	self.window.styleMask = styleMaks;
}
- (BOOL)canResize
{
	return _canResize;
}
- (void)setCanScroll:(BOOL)canScroll
{
	if(sameState(_canScroll, canScroll)) return;
	
	_canScroll = canScroll;
	
	if(canScroll) {
		[[[self.webView mainFrame] frameView] setAllowsScrolling:YES];
	} else {
		[[[self.webView mainFrame] frameView] setAllowsScrolling:NO];
	}
}
- (BOOL)canScroll
{
	return _canScroll;
}

- (NSString *)urlString
{
	return self.webView.mainFrameURL;
}
- (NSRect)contentVisibleRect
{
	return self.webView.visibleRect;
}

- (void)setWindowContentSize:(NSSize)windowContentSize
{
	NSRect contentRect;
	contentRect.origin = NSZeroPoint;
	contentRect.size = windowContentSize;
	
	NSRect newFrame = [self.window frameRectForContentRect:contentRect];
	NSRect frame = self.window.frame;
	newFrame.origin.x = NSMinX(frame);
	newFrame.origin.y = NSMaxY(frame) - NSHeight(newFrame);
	
	[self.window setFrame:newFrame display:YES];
}
- (NSSize)windowContentSize
{
	NSRect frame = self.window.frame;
	NSRect contentRect = [self.window contentRectForFrameRect:frame];
	return contentRect.size;
}

- (IBAction)reloadContent:(id)sender
{
	[self.webView reload:self];
}

- (IBAction)goHome:(id)sender
{
	self.webView.mainFrameURL = @"http://www.dmm.com/netgame/-/basket/";
}
- (IBAction)clickGoBackSegment:(id)sender
{
	NSSegmentedCell *cell = self.goSegment.cell;
	NSInteger tag = [cell tagForSegment:[cell selectedSegment]];
	switch (tag) {
		case 0:
			[self.webView goBack:self];
			break;
		case 1:
			[self.webView goForward:self];
			break;
		default:
			break;
	}
}
@end
