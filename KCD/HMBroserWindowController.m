//
//  HMBroserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBroserWindowController.h"

@interface HMBroserWindowController ()

@end

@implementation HMBroserWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (void)awakeFromNib
{
	
	NSClipView *clip = [[NSClipView alloc] initWithFrame:[self.placeholder frame]];
	[clip setAutoresizingMask:[self.placeholder autoresizingMask]];
	[[self.placeholder superview] replaceSubview:self.placeholder with:clip];
	[clip setDocumentView:self.webView];
	[clip scrollToPoint:NSMakePoint(70, 425)];
	
	[[[self.webView mainFrame] frameView] setAllowsScrolling:NO];
	
	[self.webView setApplicationNameForUserAgent:@"Version/6.0 Safari/536.25"];
	[self.webView setMainFrameURL:@"http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"];
	//	[self.webView setMainFrameURL:@"http://www.google.com/"];
	
}


@end
