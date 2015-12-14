//
//  HMGameViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/12/06.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMGameViewController.h"

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"
#import "HMScreenshotListWindowController.h"
#import "HMProgressPanel.h"

@interface HMGameViewController ()
@property NSPoint flashTopLeft;

@property (readonly) NSClipView *clipView;

@property (weak, nonatomic) IBOutlet WebView *webView;

@end

static NSString *gamePageURL = @"http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/";
static NSString *loginPageURLPrefix = @"https://www.dmm.com/my/-/login/=/";

@implementation HMGameViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}
- (void)awakeFromNib
{
	[self.clipView setDocumentView:self.webView];
	
	self.flashTopLeft = NSMakePoint(2600, 145);
	[self adjustFlash];
	
	[[[self.webView mainFrame] frameView] setAllowsScrolling:NO];
	
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	[self.webView setApplicationNameForUserAgent:appDelegate.appNameForUserAgent];
	[self.webView setMainFrameURL:gamePageURL];
	
	// for Maverick
	if(floor(NSAppKitVersionNumber) == NSAppKitVersionNumber10_9) {
		self.webView.layerUsesCoreImageFilters = YES;
	}
}

- (NSClipView *)clipView
{
	return (NSClipView *)self.view;
}

- (void)adjustFlash
{
	id /*NSClipView * */ clip = [self.webView superview];
	[clip scrollToPoint:self.flashTopLeft];
}


- (IBAction)reloadContent:(id)sender
{
	// ゲームページでない場合はゲームページを表示する
	NSString *currentURL = self.webView.mainFrameURL;
	if(![currentURL isEqualToString:gamePageURL]) {
		[self.webView setMainFrameURL:gamePageURL];
		[self adjustFlash];
		return;
	}
	if([currentURL hasPrefix:loginPageURLPrefix]) {
		[self.webView reload:sender];
		return;
	}
	
	[self adjustFlash];
	
	NSDate *prevDate = HMStandardDefaults.prevReloadDate;
	if(prevDate) {
		NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
		if([now timeIntervalSinceDate:prevDate] < 1 * 60) {
			NSDate *untilDate = [prevDate dateByAddingTimeInterval:1 * 60];
			NSString *date = [NSDateFormatter localizedStringFromDate:untilDate
															dateStyle:NSDateFormatterNoStyle
															timeStyle:NSDateFormatterMediumStyle];
			NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Reload interval is too short", @"")
											 defaultButton:nil
										   alternateButton:nil
											   otherButton:nil
								 informativeTextWithFormat:NSLocalizedString(@"Reload interval is too short.\nWait until %@.", @""), date];
			[alert runModal];
			
			return;
		}
	}
	
	[self.webView reload:sender];
	
	HMStandardDefaults.prevReloadDate = [NSDate dateWithTimeIntervalSinceNow:0];
}
- (IBAction)deleteCacheAndReload:(id)sender
{
	HMProgressPanel *panel = [HMProgressPanel new];
	panel.title = @"";
	panel.message = NSLocalizedString(@"Deleting caches...", @"Deleting caches...");
	panel.animate = YES;
	
	[self.view.window beginSheet:panel.window
		  completionHandler:^(NSModalResponse returnCode) {
			  NSSound *sound = [NSSound soundNamed:@"Submarine"];
			  [sound play];
		  }];
	
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	[appDelegate clearCache];
	[self.webView reload:sender];
	
	[self.view.window endSheet:panel.window];
}

- (IBAction)screenShot:(id)sender
{
	NSView *contentView = self.view.window.contentView;
	
	NSRect frame = [contentView convertRect:[self.webView visibleRect] fromView:self.webView];
	CGFloat screenShotBorderWidth = HMStandardDefaults.screenShotBorderWidth;
	frame = NSInsetRect(frame, -screenShotBorderWidth, -screenShotBorderWidth);
	
	NSBitmapImageRep *rep = [contentView bitmapImageRepForCachingDisplayInRect:frame];
	[contentView cacheDisplayInRect:frame toBitmapImageRep:rep];
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	HMScreenshotListWindowController *slwController = appDelegate.screenshotListWindowController;
	[slwController registerScreenshot:rep fromOnScreen:[contentView convertRect:frame toView:nil]];
	
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = menuItem.action;
	
	if(action == @selector(reloadContent:)) {
		if([self.webView.mainFrameURL isEqualToString:gamePageURL]) {
			menuItem.title = NSLocalizedString(@"Reload", @"Reload menu, reload");
		} else if ([self.webView.mainFrameURL hasPrefix:loginPageURLPrefix]) {
			menuItem.title = NSLocalizedString(@"Reload", @"Reload menu, reload");
		} else {
			menuItem.title = NSLocalizedString(@"Back To Game", @"Reload menu, back to game");
		}
		return YES;
	}
	if(action == @selector(screenShot:)) {
		return YES;
	}
	return NO;
}

#pragma mark - WebFrameLoadDelegate
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	WebDataSource *datasource = frame.dataSource;
	NSURLRequest *request = datasource.initialRequest;
	NSURL *url = request.URL;
	NSString *path = url.path;
	
	void (^handler)(JSContext *context, JSValue *exception) = ^(JSContext *context, JSValue *exception) {
		NSLog(@"caught exception in evaluateScript: -> %@", exception);
	};
	
	if([path hasSuffix:@"gadgets/ifr"]) {
		JSContext *context = [frame javaScriptContext];
		context.exceptionHandler = handler;
		[context evaluateScript:
		 @"var emb = document.getElementById('flashWrap');"
		 @"var rect = emb.getBoundingClientRect();"
		 @"var atop = rect.top;"
		 @"var aleft = rect.left;"
		 ];
		JSValue *top = context[@"atop"];
		JSValue *left = context[@"aleft"];
		
		self.flashTopLeft = NSMakePoint(0, self.webView.frame.size.height);
		self.flashTopLeft = NSMakePoint(self.flashTopLeft.x + left.toDouble, self.flashTopLeft.y - top.toDouble - 480);
	}
	
	if([path hasSuffix:@"app_id=854854"]) {
		JSContext *context = [frame javaScriptContext];
		context.exceptionHandler = handler;
		[context evaluateScript:
		 @"var iframe = document.getElementById('game_frame');"
		 @"var validIframe = 0;"
		 @"if(iframe) {"
		 @"    validIframe = 1;"
		 @"    var rect = iframe.getBoundingClientRect();"
		 @"    var atop = rect.top;"
		 @"    var aleft = rect.left;"
		 @"}"
		 ];
		int32_t validIframe = context[@"validIframe"].toInt32;
		if(validIframe == 0) {
			//			NSLog(@"game_frame is invalid");
			return;
		}
		
		JSValue *top = context[@"atop"];
		JSValue *left = context[@"aleft"];
		
		self.flashTopLeft = NSMakePoint(self.flashTopLeft.x + left.toDouble, self.flashTopLeft.y - top.toDouble);
		[self adjustFlash];
	}
}

#pragma mark - WebUIDelegate
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSMutableArray *items = [NSMutableArray new];
	for(NSMenuItem *item in defaultMenuItems) {
		switch([item tag]) {
			case WebMenuItemTagOpenLinkInNewWindow:
			case WebMenuItemTagDownloadLinkToDisk:
			case WebMenuItemTagOpenImageInNewWindow:
			case WebMenuItemTagOpenFrameInNewWindow:
			case WebMenuItemTagGoBack:
			case WebMenuItemTagGoForward:
			case WebMenuItemTagStop:
			case WebMenuItemTagReload:
				break;
			default:
				[items addObject:item];
				break;
		}
	}
	return items;
}
@end
