//
//  HMBroserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBroserWindowController.h"

#import "HMDocksViewController.h"
#import "HMShipViewController.h"
#import "HMPowerUpSupportViewController.h"

#import "HMCoreDataManager.h"


@interface HMBroserWindowController ()

@property (strong) NSViewController *selectedViewController;
@property (strong) NSMutableDictionary *controllers;

@end

@implementation HMBroserWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		_controllers = [NSMutableDictionary new];
	}
	return self;
}

- (void)awakeFromNib
{
	
	NSClipView *clip = [[NSClipView alloc] initWithFrame:[self.placeholder frame]];
	[clip setAutoresizingMask:[self.placeholder autoresizingMask]];
	[[self.placeholder superview] replaceSubview:self.placeholder with:clip];
	[clip setDocumentView:self.webView];
	[clip scrollToPoint:NSMakePoint(70, 425)];
	
	self.selectedViewController = [HMDocksViewController new];
	[self.selectedViewController.view setFrame:[self.docksPlaceholder frame]];
	[self.selectedViewController.view setAutoresizingMask:[self.docksPlaceholder autoresizingMask]];
	[[self.docksPlaceholder superview] replaceSubview:self.docksPlaceholder with:self.selectedViewController.view];
	[self.controllers setObject:self.selectedViewController forKey:@0];
	
	
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

- (void)showViewWithNumber:(NSInteger)number
{
	Class controllerClass = Nil;

	switch (number) {
		case 0:
			controllerClass = [HMDocksViewController class];
			break;
		case 1:
			controllerClass = [HMShipViewController class];
			break;
		case 2:
			controllerClass = [HMPowerUpSupportViewController class];
			break;
		default:
			break;
	}
	
	if(!controllerClass) return;
	if([self.selectedViewController isMemberOfClass:controllerClass]) return;
	
	NSViewController *newContoller = [self.controllers objectForKey:@(number)];
	if(!newContoller) {
		newContoller = [controllerClass new];
		[self.controllers setObject:newContoller forKey:@(number)];
	}
	[newContoller.view setFrame:[self.selectedViewController.view frame]];
	[newContoller.view setAutoresizingMask:[self.selectedViewController.view autoresizingMask]];
	[[self.selectedViewController.view superview] replaceSubview:self.selectedViewController.view with:newContoller.view];
	self.selectedViewController = newContoller;
	
	self.selectedViewsSegment = number;
}

- (IBAction)reloadContent:(id)sender
{
	id /*NSClipView * */ clip = [self.webView superview];
	[clip scrollToPoint:NSMakePoint(70, 425)];
	[self.webView reload:sender];
}


- (IBAction)selectView:(id)sender
{
	NSInteger tag = -1;
	if([sender respondsToSelector:@selector(selectedSegment)]) {
		NSSegmentedCell *cell = [sender cell];
		NSUInteger index = [sender selectedSegment];
		tag = [cell tagForSegment:index];
	} else {
		tag = [sender tag];
	}
	[self showViewWithNumber:tag];
}

@end
