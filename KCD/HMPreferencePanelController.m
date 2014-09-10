//
//  HMPreferencePanelController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPreferencePanelController.h"

#import "HMAppDelegate.h"

typedef NS_ENUM(NSUInteger, HMScreenShotSaveDirectoryPopUpMenuItemTag) {
    kSaveDirectoryItem = 1000,
    kSelectDirectoryItem = 2000,
};

@interface HMPreferencePanelController ()

@property (nonatomic, strong) NSURL *screenShotSaveURL;
@end

@implementation HMPreferencePanelController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (void)awakeFromNib
{
	HMAppDelegate *appDelegate = [NSApp delegate];
	self.screenShotSaveDirectory = appDelegate.screenShotSaveDirectory;
}

- (NSString *)screenShotSaveDirectory
{
	HMAppDelegate *appDelegate = [NSApp delegate];
	return appDelegate.screenShotSaveDirectory;
}
- (void)setScreenShotSaveDirectory:(NSString *)screenShotSaveDirectory
{
	HMAppDelegate *appDelegate = [NSApp delegate];
	appDelegate.screenShotSaveDirectory = screenShotSaveDirectory;
	
	NSInteger index = [self.screenShotSaveDirectoryPopUp indexOfItemWithTag:kSaveDirectoryItem];
	NSMenuItem *item = [self.screenShotSaveDirectoryPopUp itemAtIndex:index];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSImage *icon = [ws iconForFile:screenShotSaveDirectory];
	NSSize iconSize = [icon size];
	CGFloat height = 16;
	[icon setSize:NSMakeSize(iconSize.width * height / iconSize.height, height)];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *title = [fm displayNameAtPath:screenShotSaveDirectory];
	
	[item setImage:icon];
	[item setTitle:title];
}


- (IBAction)selectScreenShotSaveDirectory:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	
	[panel beginSheetModalForWindow:self.window
				  completionHandler:^(NSInteger result) {
					  if(result == NSCancelButton) return;
					  
					  self.screenShotSaveDirectory = panel.URL.path;
				  }];
}

- (IBAction)selectScreenShotSaveDirectoryPopUp:(id)sender
{
	NSUInteger tag = [sender tag];
	if(tag != kSelectDirectoryItem) return;
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	
	[panel beginSheetModalForWindow:self.window
				  completionHandler:^(NSInteger result) {
					  [self.screenShotSaveDirectoryPopUp selectItemWithTag:kSaveDirectoryItem];
					  
					  if(result == NSCancelButton) return;
					  
					  self.screenShotSaveDirectory = panel.URL.path;
				  }];
}

@end
