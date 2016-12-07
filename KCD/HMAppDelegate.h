//
//  HMAppDelegate.h
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMJSONViewWindowController.h"

@class HMFleetManager;
@class HMExternalBrowserWindowController;

@class HMScreenshotListWindowController;

@interface HMAppDelegate : NSObject <NSApplicationDelegate>

- (void)logLineReturn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (void)addCounterUpdateBlock:(void(^)())updater;

@property (nonatomic, strong) IBOutlet NSMenuItem *debugMenuItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *billingWindowMenuItem;

@property (nonatomic, readonly) HMFleetManager *fleetManager;

@property (nonatomic, copy) NSString *screenShotSaveDirectory;
@property (nonatomic, readonly) HMScreenshotListWindowController *screenshotListWindowController;

@property (nonatomic, readonly) NSURL *supportDirectory;

- (IBAction)showHideHistory:(id)sender;
- (IBAction)showHideSlotItemWindow:(id)sender;
- (IBAction)showHideUpgradableShipWindow:(id)sender;
- (IBAction)showHideScreenshotListWindow:(id)sender;

- (IBAction)showHidePreferencePanle:(id)sender;

- (IBAction)showWindowAduster:(id)sender;

- (IBAction)saveLocalData:(id)sender;
- (IBAction)loadLocalData:(id)sender;

- (IBAction)openNewBrowser:(id)sender;

- (void)clearCache;

- (HMExternalBrowserWindowController *)createNewBrowser;

#if ENABLE_JSON_LOG
@property (strong) HMJSONViewWindowController *jsonViewWindowController;
#endif

@property (readonly) NSString *appNameForUserAgent;

@end

// defined in HMPortNotifyCommand.m
// notification have no userinfo.
extern NSString *HMPortAPIRecieveNotification;

