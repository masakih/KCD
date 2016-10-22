//
//  HMPreferencePanelController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPreferencePanelController.h"

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"

typedef NS_ENUM(NSInteger, HMPreferencePaneType) {
    kGeneral = 1,
    kNotification = 2,
};

typedef NS_ENUM(NSUInteger, HMScreenShotSaveDirectoryPopUpMenuItemTag) {
    kSaveDirectoryItem = 1000,
    kSelectDirectoryItem = 2000,
};

@interface HMPreferencePanelController ()

@property (nonatomic, strong) NSURL *screenShotSaveURL;

@property (nonatomic, weak) IBOutlet NSPopUpButton *screenShotSaveDirectoryPopUp;
@property (nonatomic, weak) IBOutlet NSView *generalPane;
@property (nonatomic, weak) IBOutlet NSView *notificationPane;
@end

@implementation HMPreferencePanelController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (void)awakeFromNib
{
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	self.screenShotSaveDirectory = appDelegate.screenShotSaveDirectory;
    
    NSArray *items = self.window.toolbar.items;
    if(items.count != 0) {
        NSToolbarItem *item = items.firstObject;
        self.window.toolbar.selectedItemIdentifier = item.itemIdentifier;
        [NSApp sendAction:@selector(didChangeSelection:)
                       to:self
                     from:item];
        [self.window center];
    }
}

#pragma mark - Screen Shot
- (NSString *)screenShotSaveDirectory
{
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	return appDelegate.screenShotSaveDirectory;
}
- (void)setScreenShotSaveDirectory:(NSString *)screenShotSaveDirectory
{
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
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
					  if(result == NSModalResponseCancel) return;
					  
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
					  
					  if(result == NSModalResponseCancel) return;
					  
					  self.screenShotSaveDirectory = panel.URL.path;
				  }];
}

- (IBAction)didChangeSelection:(id)sender
{
    NSInteger tag = [sender tag];
    NSView *newPane = nil;
    switch(tag) {
        case kGeneral:
            newPane = self.generalPane;
            break;
        case kNotification:
            newPane = self.notificationPane;
            break;
    }
    
    if(!newPane) return;
    
    NSToolbarItem *item = (NSToolbarItem *)sender;
    self.window.title = item.label;
    
    NSArray *subviews = self.window.contentView.subviews;
    for(NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    NSRect windowRect = self.window.frame;
    NSRect newWindowRect = [self.window frameRectForContentRect:newPane.frame];
    newWindowRect.origin.x = windowRect.origin.x;
    newWindowRect.origin.y = windowRect.origin.y + windowRect.size.height - newWindowRect.size.height;
    [self.window setFrame:newWindowRect display:YES animate:YES];
    
    [self.window.contentView addSubview:newPane];
}

@end
