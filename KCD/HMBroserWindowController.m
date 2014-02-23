//
//  HMBroserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBroserWindowController.h"

#import "HMDocksViewController.h"
#import "HMCoreDataManager.h"


@interface HMBroserWindowController ()

@property (strong) HMDocksViewController *dockViewController;

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
	
	self.dockViewController = [HMDocksViewController new];
	[self.dockViewController.view setFrame:[self.docksPlaceholder frame]];
	[self.dockViewController.view setAutoresizingMask:[self.docksPlaceholder autoresizingMask]];
	[[self.docksPlaceholder superview] replaceSubview:self.docksPlaceholder with:self.dockViewController.view];
	
	
	[[[self.webView mainFrame] frameView] setAllowsScrolling:NO];
	
	[self.webView setApplicationNameForUserAgent:@"Version/6.0 Safari/536.25"];
	[self.webView setMainFrameURL:@"http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"];
	//	[self.webView setMainFrameURL:@"http://www.google.com/"];
	
}


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

- (NSAttributedString *)linksString
{
	NSBundle *main = [NSBundle mainBundle];
	NSURL *url = [main URLForResource:@"Links" withExtension:@"rtf"];
	NSAttributedString *linksString = [[NSAttributedString alloc] initWithURL:url documentAttributes:nil];
	
	return linksString;
}


@end
