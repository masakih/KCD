//
//  HMUITestWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/02/28.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMUITestWindowController.h"

@interface HMUITestWindowController ()
@property (nonatomic, weak) IBOutlet NSView *testViewPlaceholder;

@property (nonatomic, strong) NSViewController *testViewController;
@end

@implementation HMUITestWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (Class)testViewControllerClass
{
	return NSClassFromString(@"HMFleetTestViewController");
}

- (void)windowDidLoad {
    [super windowDidLoad];
//	
//	self.testViewController = [self.testViewControllerClass new];
//	NSRect frame = self.testViewController.view.frame;
//	self.window.contentSize = frame.size;
////	[self.testViewController.view setFrame:[self.testViewPlaceholder frame]];
//	[self.testViewController.view setAutoresizingMask:[self.testViewPlaceholder autoresizingMask]];
//	[[self.testViewPlaceholder superview] replaceSubview:self.testViewPlaceholder with:self.testViewController.view];
}

@end
