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

@end

@implementation HMExternalBrowserWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (void)awakeFromNib
{
	[self goHome:nil];
	
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

/*
 
 
 http://www.dmm.com/netgame/-/basket/
 
 */

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
