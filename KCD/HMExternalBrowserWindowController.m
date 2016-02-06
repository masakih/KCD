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
#import "HMBookmarkListViewController.h"



@interface HMExternalBrowserWindowController () <HMBookmarkListViewControllerDelegate, NSAnimationDelegate, WebFrameLoadDelegate>
@property (nonatomic, weak) IBOutlet NSSegmentedControl *goSegment;

@property (nonatomic, weak) IBOutlet NSView *bookmarkListView;
@property (strong) HMBookmarkListViewController *bookmarkListViwController;

@property (readwrite) NSRect contentVisibleRect;

@property (weak) HMBookmarkItem *waitingBookmarkItem;


@property BOOL bookarkShowing;
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
//	self.webView.wantsLayer = YES;
	
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
	self.canMovePage = YES;
	self.bookarkShowing = NO;
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

- (NSManagedObjectContext *)managedObjectContext
{
	return [[HMBookmarkManager sharedManager] manageObjectContext];
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


- (void)setBookmark:(HMBookmarkItem *)bookmark
{
	if(!self.canMovePage) {
		HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
		HMExternalBrowserWindowController *newController = [appDelegate createNewBrowser];
		[newController setBookmark:bookmark];
		return;
	}
	self.webView.mainFrameURL = bookmark.urlString;
	self.windowContentSize = bookmark.windowContentSize;
	self.canResize = bookmark.canResize;
	self.canScroll = bookmark.canScroll;
	self.waitingBookmarkItem = bookmark;
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
	
	[self setBookmark:item];
}

- (IBAction)reloadContent:(id)sender
{
	[self.webView reload:self];
}

- (IBAction)goHome:(id)sender
{
	self.webView.mainFrameURL = @"http://www.dmm.com/";
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
	HMBookmarkItem *bookmark = [bookmarkManager createNewBookmark];
	bookmark.name = self.window.title;
	bookmark.urlString = self.webView.mainFrameURL;
	bookmark.windowContentSize = self.windowContentSize;
	bookmark.contentVisibleRect = self.contentVisibleRect;
	bookmark.canResize = self.canResize;
	bookmark.canScroll = self.canScroll;
	bookmark.scrollDelay = 0.5;
}
- (BOOL)showsBookmarkList
{
	return self.webView.frame.origin.x > 0;
}
- (IBAction)showBookmark:(id)sender
{
	if(self.bookarkShowing) return;
	self.bookarkShowing = YES;
	
	if(!self.bookmarkListViwController) {
		self.bookmarkListViwController = [HMBookmarkListViewController new];
		self.bookmarkListView = self.bookmarkListViwController.view;
		self.bookmarkListViwController.delegate = self;
		
		
		NSRect frame = self.webView.frame;
		frame.size.width = 200;
		frame.origin.x = -200;
		self.bookmarkListView.frame = frame;
		NSView *view = self.webView.superview;
		[view addSubview:self.bookmarkListView
			  positioned:NSWindowBelow
			  relativeTo:self.webView];
	}
	
	NSRect webViewFrame = self.webView.frame;
	NSRect frame = self.bookmarkListView.frame;
	frame.size.height = webViewFrame.size.height;
	self.bookmarkListView.frame = frame;
	
	NSRect newFrame = webViewFrame;
	
	if([self showsBookmarkList]) {
		frame.origin.x = -200;
		newFrame.origin.x = 0;
		newFrame.size.width = self.window.frame.size.width;
	} else {
		frame.origin.x = 0;
		newFrame.origin.x = 200;
		newFrame.size.width = self.window.frame.size.width - 200;
	}
	
	
	NSDictionary *webViewAnime = @{
							   NSViewAnimationTargetKey : self.webView,
							   NSViewAnimationEndFrameKey : [NSValue valueWithRect:newFrame],
							   };
	NSDictionary *bookMarkAnime = @{
								   NSViewAnimationTargetKey : self.bookmarkListView,
								   NSViewAnimationEndFrameKey : [NSValue valueWithRect:frame],
								   };
	NSAnimation *anime = [[NSViewAnimation alloc] initWithViewAnimations:@[webViewAnime, bookMarkAnime]];
	anime.delegate = self;
	[anime startAnimation];
}
- (void)animationDidEnd:(NSAnimation *)animation
{
	self.bookarkShowing = NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	if(action == @selector(addBookmark:)) {
		return self.webView.mainFrameURL != nil;
	}
	if(action == @selector(showBookmark:)) {
		if([self showsBookmarkList]) {
			menuItem.title = NSLocalizedString(@"Hide Bookmark", @"Menu item title, Hide Bookmark");
		} else {
			menuItem.title = NSLocalizedString(@"Show Bookmark", @"Menu item title, Show Bookmark");
		}
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

- (IBAction)scrollLeft:(id)sender
{
	NSRect rect = self.contentVisibleRect;
	rect.origin.x += 1;
	self.contentVisibleRect = rect;
}
- (IBAction)scrollRight:(id)sender
{
	NSRect rect = self.contentVisibleRect;
	rect.origin.x -= 1;
	self.contentVisibleRect = rect;
}
- (IBAction)scrollUp:(id)sender
{
	NSRect rect = self.contentVisibleRect;
	rect.origin.y += 1;
	self.contentVisibleRect = rect;
}
- (IBAction)scrollDown:(id)sender
{
	NSRect rect = self.contentVisibleRect;
	rect.origin.y -= 1;
	self.contentVisibleRect = rect;
}
- (IBAction)increaseWidth:(id)sender
{
	NSRect frame = self.window.frame;
	frame.size.width += 1;
	[self.window setFrame:frame display:YES];
}
- (IBAction)decreaseWidth:(id)sender
{
	NSRect frame = self.window.frame;
	frame.size.width -= 1;
	[self.window setFrame:frame display:YES];
}
- (IBAction)increaseHeight:(id)sender
{
	NSRect frame = self.window.frame;
	frame.size.height += 1;
	frame.origin.y -= 1;
	[self.window setFrame:frame display:YES];
}
- (IBAction)decreaseHeight:(id)sender
{
	NSRect frame = self.window.frame;
	frame.size.height -= 1;
	frame.origin.y += 1;
	[self.window setFrame:frame display:YES];
}


- (void)swipeWithEvent:(NSEvent *)event
{
	if([event deltaX] > 0 && [self showsBookmarkList]) {
		[self showBookmark:nil];
	}
	if([event deltaX] < 0 && ![self showsBookmarkList]) {
		[self showBookmark:nil];
	}
}

- (void)didSelectBookmark:(HMBookmarkItem *)bookmark
{
	[self setBookmark:bookmark];
}


#pragma mark - WebFrameLoadDelegate
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

#pragma mark - WebPolicyDelegate
- (void)webView:(WebView *)webView
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
		  frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener
{
	if(actionInformation && [actionInformation[WebActionNavigationTypeKey] integerValue] == WebNavigationTypeLinkClicked) {
		if(self.canMovePage) {
			[listener use];
		}
		return;
	}
	[listener use];
}

@end
