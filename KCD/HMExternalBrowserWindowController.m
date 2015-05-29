//
//  HMExternalBrowserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/11/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMExternalBrowserWindowController.h"

#import "HMAppDelegate.h"
#import "HMBookmarkManager.h"


@interface HMExternalBrowserWindowController ()
@property (nonatomic, weak) IBOutlet NSSegmentedControl *goSegment;

@property (readwrite) NSRect contentVisibleRect;

@property (weak) HMBookmarkItem *waitingBookmarkItem;
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
	self.webView.frameLoadDelegate = self;
	
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
- (void)setContentVisibleRect:(NSRect)contentVisibleRect
{
	[self.webView.mainFrame.frameView.documentView scrollRectToVisible:contentVisibleRect];
}
- (NSRect)contentVisibleRect
{
	return self.webView.mainFrame.frameView.documentView.visibleRect;
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


- (void)updateContentVisibleRect:(NSTimer *)timer
{
	HMBookmarkItem *item = [timer userInfo];
	self.contentVisibleRect = item.contentVisibleRect;
}
- (IBAction)selectBookmark:(id)sender
{
	HMBookmarkItem *item = [sender representedObject];
	if(!item) return;
	
	self.webView.mainFrameURL = item.urlString;
	self.windowContentSize = item.windowContentSize;
	self.canResize = item.canResize;
	self.canScroll = item.canScroll;
	self.waitingBookmarkItem = item;
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
- (IBAction)addBookmark:(id)sender
{
	HMBookmarkManager *bookmarkManager = [HMBookmarkManager sharedManager];
	HMBookmarkItem *bookmark = [HMBookmarkItem new];
	bookmark.name = self.window.title;
	bookmark.urlString = self.webView.mainFrameURL;
	bookmark.windowContentSize = self.windowContentSize;
	bookmark.contentVisibleRect = self.contentVisibleRect;
	bookmark.canResize = self.canResize;
	bookmark.canScroll = self.canScroll;
	bookmark.scrollDelay = 0.5;
	
	[bookmarkManager addBookmark:bookmark];
}
- (IBAction)editBookmark:(id)sender
{
	
}
- (IBAction)showBookmark:(id)sender
{
	HMBookmarkManager *bookmarkManager = [HMBookmarkManager sharedManager];
	NSLog(@"Bookmarks -> %@", bookmarkManager.bookmarks);
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	if(action == @selector(addBookmark:)) {
		return self.webView.mainFrameURL != nil;
	}
	if(action == @selector(editBookmark:)) {
		return YES;
	}
	if(action == @selector(showBookmark:)) {
		return YES;
	}
	if(action == @selector(selectBookmark:)) {
		return YES;
	}
	if(action == @selector(reloadContent:)) {
		return YES;
	}
	
	return NO;
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if(self.waitingBookmarkItem) {
		[NSTimer scheduledTimerWithTimeInterval:self.waitingBookmarkItem.scrollDelay
										 target:self
									   selector:@selector(updateContentVisibleRect:)
									   userInfo:self.waitingBookmarkItem
										repeats:NO];
		self.waitingBookmarkItem = nil;
	}
}
@end
