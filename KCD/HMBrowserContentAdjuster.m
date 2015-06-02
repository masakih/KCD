//
//  HMBrowserContentAdjuster.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/02.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBrowserContentAdjuster.h"

#import "HMExternalBrowserWindowController.h"


@interface HMBrowserContentAdjuster ()

@end

@implementation HMBrowserContentAdjuster

- (instancetype)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (HMExternalBrowserWindowController *)mainExternalWindowController
{
	NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
	id controller = mainWindow.windowController;
	if([controller isKindOfClass:[HMExternalBrowserWindowController class]]) {
		return controller;
	}
	return nil;
}
@end
