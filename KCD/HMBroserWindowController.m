//
//  HMBroserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBroserWindowController.h"

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"
#import "HMDocksViewController.h"
#import "HMShipViewController.h"
#import "HMPowerUpSupportViewController.h"
#import "HMStrengthenListViewController.h"

#import "HMFleetViewController.h"

#import "HMProgressPanel.h"
#import "HMScreenshotListWindowController.h"

#import "HMServerDataStore.h"

#import <JavaScriptCore/JavaScriptCore.h>


typedef NS_ENUM(NSInteger, ViewType) {
	kScheduleType = 0,
	kOrganizeType = 1,
	kPowerUpType = 2,
};

typedef NS_ENUM(NSUInteger, FleetViewPosition) {
	kAbove,
	kBelow,
	kDivided,
	
	kOldStyle = 0xffffffff,
};

static NSString *gamePageURL = @"http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/";
static NSString *loginPageURLPrefix = @"https://www.dmm.com/my/-/login/=/";

@interface HMBroserWindowController ()
@property NSPoint flashTopLeft;

@property (strong) NSNumber *flagShipID;

@property (strong) HMFleetViewController *fleetViewController;
@property FleetViewPosition fleetViewPosition;

@property (weak) IBOutlet NSTabView *informations;
@property (strong) HMDocksViewController *docksViewController;
@property (strong) HMShipViewController *shipViewController;
@property (strong) HMPowerUpSupportViewController *powerUpViewController;
@property (strong) HMStrengthenListViewController *strengthedListViewController;

@end

@implementation HMBroserWindowController
@synthesize fleetViewPosition = _fleetViewPosition;

+ (NSSet *)keyPathsForValuesAffectingFlagShipName
{
	return [NSSet setWithObject:@"flagShipID"];
}

+ (NSSet *)keyPathsForValuesAffectingShipNumberColor
{
	return [NSSet setWithObjects:@"maxChara", @"shipCount", @"minimumColoredShipCount", nil];
}

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		[self loadWindow];
	}
	return self;
}

- (IBAction)left:(id)sender
{
	NSPoint o = self.flashTopLeft;
	o.x -= 10;
	self.flashTopLeft = o;
	[self adjustFlash];
}
- (IBAction)right:(id)sender
{
	NSPoint o = self.flashTopLeft;
	o.x += 10;
	self.flashTopLeft = o;
	[self adjustFlash];
}
- (IBAction)top:(id)sender
{
	NSPoint o = self.flashTopLeft;
	o.y += 10;
	self.flashTopLeft = o;
	[self adjustFlash];
}
- (IBAction)bottom:(id)sender
{
	NSPoint o = self.flashTopLeft;
	o.y -= 10;
	self.flashTopLeft = o;
	[self adjustFlash];
}

- (void)awakeFromNib
{
	
	NSClipView *clip = [[NSClipView alloc] initWithFrame:[self.placeholder frame]];
	[clip setAutoresizingMask:[self.placeholder autoresizingMask]];
	[[self.placeholder superview] replaceSubview:self.placeholder with:clip];
	[clip setDocumentView:self.webView];
	self.placeholder = clip;
	
	self.flashTopLeft = NSMakePoint(2600, 145);
	[self adjustFlash];
	
	self.docksViewController = [HMDocksViewController new];
	self.shipViewController = [HMShipViewController new];
	self.powerUpViewController = [HMPowerUpSupportViewController new];
	self.strengthedListViewController = [HMStrengthenListViewController new];
	NSTabViewItem *item = [self.informations tabViewItemAtIndex:0];
	item.view = self.docksViewController.view;
	item = [self.informations tabViewItemAtIndex:1];
	item.view = self.shipViewController.view;
	item = [self.informations tabViewItemAtIndex:2];
	item.view = self.powerUpViewController.view;
	item = [self.informations tabViewItemAtIndex:3];
	item.view = self.strengthedListViewController.view;
	
	_fleetViewController = [[HMFleetViewController alloc] initWithViewType:detailViewType];
	[self.fleetViewController.view setFrame:[self.deckPlaceholder frame]];
	[self.fleetViewController.view setAutoresizingMask:[self.deckPlaceholder autoresizingMask]];
	[[self.deckPlaceholder superview] replaceSubview:self.deckPlaceholder with:self.fleetViewController.view];
	_fleetViewPosition = kBelow;
	[self setFleetViewPosition:HMStandardDefaults.fleetViewPosition animation:NO];
	self.fleetViewController.enableAnimation = NO;
	self.fleetViewController.shipOrder = HMStandardDefaults.fleetViewShipOrder;
	self.fleetViewController.enableAnimation = YES;
	
	[[[self.webView mainFrame] frameView] setAllowsScrolling:NO];
	
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	[self.webView setApplicationNameForUserAgent:appDelegate.appNameForUserAgent];
	[self.webView setMainFrameURL:gamePageURL];
	
	// for Maverick
	if(floor(NSAppKitVersionNumber) == NSAppKitVersionNumber10_9) {
		self.webView.layerUsesCoreImageFilters = YES;
	}
	
	[self bind:@"flagShipID" toObject:self.deckContoller withKeyPath:@"selection.ship_0" options:nil];
	
	[self bind:@"maxChara" toObject:self.basicController withKeyPath:@"selection.max_chara" options:nil];
	[self bind:@"shipCount" toObject:self.shipController withKeyPath:@"arrangedObjects.@count" options:nil];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (NSAttributedString *)linksString
{
	NSBundle *main = [NSBundle mainBundle];
	NSURL *url = [main URLForResource:@"Links" withExtension:@"rtf"];
	NSAttributedString *linksString = [[NSAttributedString alloc] initWithURL:url documentAttributes:nil];
	
	return linksString;
}

- (void)showViewWithNumber:(ViewType)type
{
	[self.informations selectTabViewItemAtIndex:type];
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
	
	[self.window beginSheet:panel.window
				  completionHandler:^(NSModalResponse returnCode) {
					  NSSound *sound = [NSSound soundNamed:@"Submarine"];
					  [sound play];
				  }];
	
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	[appDelegate clearCache];
	[self reloadContent:sender];
	
	[self.window endSheet:panel.window];
}

- (NSString *)flagShipName
{
	NSError *error = nil;
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", self.flagShipID];
	[request setPredicate:predicate];
	NSArray *array = [self.managedObjectContext executeFetchRequest:request
													 error:&error];
	if([array count] == 0) {
		return nil;
	}
	
	id flagShipName = [array[0] valueForKeyPath:@"master_ship.name"];
	if(!flagShipName || [flagShipName isKindOfClass:[NSNull class]]) {
		return nil;
	}
	
	return flagShipName;
}

- (NSColor *)shipNumberColor
{
	NSInteger max = self.maxChara.integerValue;
	NSInteger current = self.shipCount.integerValue;
	
	if(current > max - self.minimumColoredShipCount) {
		return [NSColor orangeColor];
	}
	
	return [NSColor controlTextColor];
}
- (void)setMinimumColoredShipCount:(NSInteger)minimumColoredShipCount
{
	HMStandardDefaults.minimumColoredShipCount = minimumColoredShipCount;
}
- (NSInteger)minimumColoredShipCount
{
	return HMStandardDefaults.minimumColoredShipCount;
}

- (IBAction)selectView:(id)sender
{
	[self showViewWithNumber:[sender tag]];
}
- (IBAction)screenShot:(id)sender
{
	NSView *contentView = self.window.contentView;
	
	NSRect frame = [contentView convertRect:[self.webView visibleRect] fromView:self.webView];
	CGFloat screenShotBorderWidth = HMStandardDefaults.screenShotBorderWidth;
	frame = NSInsetRect(frame, -screenShotBorderWidth, -screenShotBorderWidth);
	
	NSBitmapImageRep *rep = [contentView bitmapImageRepForCachingDisplayInRect:frame];
	[contentView cacheDisplayInRect:frame toBitmapImageRep:rep];
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	HMScreenshotListWindowController *slwController = appDelegate.screenshotListWindowController;
	[slwController registerScreenshot:rep fromOnScreen:[contentView convertRect:frame toView:nil]];
	
}


#pragma mark - FleetView position
// ###############################
const CGFloat margin = 1;
const CGFloat flashTopMargin = 4;
// ###############################


- (void)changeFleetViewForFleetViewPositionIfNeeded:(FleetViewPosition)fleetViewPosition
{
	if(self.fleetViewPosition == fleetViewPosition) return;
	if(self.fleetViewPosition != kOldStyle && fleetViewPosition != kOldStyle) return;
	
	HMFleetViewType type = fleetViewPosition == kOldStyle ? minimumViewType : detailViewType;
	
	HMFleetViewController *newController = [[HMFleetViewController alloc] initWithViewType:type];
	newController.enableAnimation = YES;
	newController.shipOrder = self.fleetViewController.shipOrder;
	
	NSView *currentView = self.fleetViewController.view;
	NSRect newFrame = newController.view.frame;
	newFrame.origin = currentView.frame.origin;
	newController.view.frame = newFrame;
	[currentView.superview replaceSubview:currentView with:newController.view];
	
	self.fleetViewController = newController;
}

- (CGFloat)windowHeightForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	CGFloat windowContentHeight = [self.window.contentView frame].size.height;
	
	if(self.fleetViewPosition == fleetViewPosition) return windowContentHeight;
	
	if(self.fleetViewPosition == kOldStyle) {
		windowContentHeight += HMFleetViewController.heightDifference;
	}
	if(fleetViewPosition == kOldStyle) {
		windowContentHeight -= HMFleetViewController.heightDifference;
	}
	
	return windowContentHeight;
}
- (NSRect)windowFrameForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	NSRect windowContentRect = [self.window frame];
	
	if(self.fleetViewPosition == fleetViewPosition) return windowContentRect;
	
	if(self.fleetViewPosition == kOldStyle) {
		windowContentRect.size.height += HMFleetViewController.heightDifference;
		windowContentRect.origin.y -= HMFleetViewController.heightDifference;
	}
	if(fleetViewPosition == kOldStyle) {
		windowContentRect.size.height -= HMFleetViewController.heightDifference;
		windowContentRect.origin.y += HMFleetViewController.heightDifference;
	}
	
	return windowContentRect;
}

- (NSRect)flashFrameForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	CGFloat flashY;
	
	CGFloat windowContentHeight = [self windowHeightForFleetViewPosition:fleetViewPosition];
	NSRect flashRect = self.placeholder.frame;
	
	switch(fleetViewPosition) {
		case kAbove:
			flashY = windowContentHeight - flashRect.size.height - self.fleetViewController.normalHeight;
			break;
		case kBelow:
			flashY = windowContentHeight - flashRect.size.height;
			break;
		case kDivided:
			flashY = windowContentHeight - flashRect.size.height - self.fleetViewController.upsideHeight - margin;
			break;
		case kOldStyle:
			flashY = windowContentHeight - flashRect.size.height - flashTopMargin;
			break;
		default:
			NSLog(@"%s: unknown position.", __PRETTY_FUNCTION__);
			return NSZeroRect;
	}
	
	flashRect.origin.y = flashY;
	return flashRect;
}

- (NSRect)fleetViewFrameForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	CGFloat fleetViewHeight;
	CGFloat fleetViewY;
	
	CGFloat windowContentHeight = [self windowHeightForFleetViewPosition:fleetViewPosition];
	NSRect flashRect = self.placeholder.frame;
	NSRect fleetListRect = self.fleetViewController.view.frame;
	
	switch(fleetViewPosition) {
		case kAbove:
			fleetViewHeight = self.fleetViewController.normalHeight;
			fleetViewY = windowContentHeight - fleetViewHeight;
			break;
		case kBelow:
			fleetViewHeight = self.fleetViewController.normalHeight;
			fleetViewY = windowContentHeight - fleetViewHeight - flashRect.size.height - margin;
			break;
		case kDivided:
			fleetViewHeight = self.fleetViewController.normalHeight + flashRect.size.height + margin + margin;
			fleetViewY = windowContentHeight - fleetViewHeight;
			break;
		case kOldStyle:
			fleetViewHeight = HMFleetViewController.oldStyleFleetViewHeight;
			fleetViewY = windowContentHeight - fleetViewHeight - flashRect.size.height - margin - flashTopMargin;
			break;
		default:
			NSLog(@"%s: unknown position.", __PRETTY_FUNCTION__);
			return NSZeroRect;
	}
	
	fleetListRect.size.height = fleetViewHeight;
	fleetListRect.origin.y = fleetViewY;
	return fleetListRect;
}

- (void)setFleetViewPosition:(FleetViewPosition)fleetViewPosition animation:(BOOL)flag
{
	[self changeFleetViewForFleetViewPositionIfNeeded:fleetViewPosition];
	
	NSRect windowFrame = [self windowFrameForFleetViewPosition:fleetViewPosition];
	NSRect flashRect = [self flashFrameForFleetViewPosition:fleetViewPosition];
	NSRect fleetListRect = [self fleetViewFrameForFleetViewPosition:fleetViewPosition];
	
	_fleetViewPosition = fleetViewPosition;
	HMStandardDefaults.fleetViewPosition = fleetViewPosition;
	
	if(flag) {
		NSDictionary *winAnime = @{
								   NSViewAnimationTargetKey : self.window,
								   NSViewAnimationEndFrameKey : [NSValue valueWithRect:windowFrame],
								   };
		NSDictionary *flashAnime = @{
						   NSViewAnimationTargetKey : self.placeholder,
						   NSViewAnimationEndFrameKey : [NSValue valueWithRect:flashRect],
						   };
		NSDictionary *fleetAnime = @{
								 NSViewAnimationTargetKey : self.fleetViewController.view,
								 NSViewAnimationEndFrameKey : [NSValue valueWithRect:fleetListRect],
								 };
		NSAnimation *anime = [[NSViewAnimation alloc] initWithViewAnimations:@[winAnime, flashAnime, fleetAnime]];
		[anime startAnimation];
	} else {
		[self.window setFrame:windowFrame display:NO];
		self.placeholder.frame = flashRect;
		self.fleetViewController.view.frame = fleetListRect;
	}
}

- (void)setFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	[self setFleetViewPosition:fleetViewPosition animation:YES];
}
- (FleetViewPosition)fleetViewPosition
{
	return _fleetViewPosition;
}
- (IBAction)fleetListAbove:(id)sender
{
	self.fleetViewPosition = kAbove;
}
- (IBAction)fleetListBelow:(id)sender
{
	self.fleetViewPosition = kBelow;
}
- (IBAction)fleetListDivide:(id)sender
{
	self.fleetViewPosition = kDivided;
}
- (IBAction)fleetListSimple:(id)sender
{
	self.fleetViewPosition = kOldStyle;
}

- (IBAction)reorderToDoubleLine:(id)sender
{
	self.fleetViewController.shipOrder = doubleLine;
	HMStandardDefaults.fleetViewShipOrder = doubleLine;
}
- (IBAction)reorderToLeftToRight:(id)sender
{
	self.fleetViewController.shipOrder = leftToRight;
	HMStandardDefaults.fleetViewShipOrder = leftToRight;
}

- (IBAction)selectNextFleet:(id)sender
{
	[_fleetViewController selectNextFleet:sender];
}
- (IBAction)selectPreviousFleet:(id)sender
{
	[_fleetViewController selectPreviousFleet:sender];
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
	if(action == @selector(deleteCacheAndReload:)) {
		return YES;
	}
	if(action == @selector(selectView:)) {
		return YES;
	}
	if(action == @selector(screenShot:)) {
		return YES;
	}
	if(action == @selector(selectNextFleet:) || action == @selector(selectPreviousFleet:)) {
		return YES;
	}
	
	if(action == @selector(fleetListAbove:)) {
		if(self.fleetViewPosition == kAbove) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(fleetListBelow:)) {
		if(self.fleetViewPosition == kBelow) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(fleetListDivide:)) {
		if(self.fleetViewPosition == kDivided) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(fleetListSimple:)) {
		if(self.fleetViewPosition == kOldStyle) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	
	if(action == @selector(reorderToDoubleLine:)) {
		if(self.fleetViewController.shipOrder == doubleLine) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(reorderToLeftToRight:)) {
		if(self.fleetViewController.shipOrder == leftToRight) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
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
