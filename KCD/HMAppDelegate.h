//
//  HMAppDelegate.h
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMJSONViewWindowController.h"

@class HMFleetInformation;

typedef NS_ENUM(NSUInteger, HMShipType) {
    kHMAllType,
    kHMDestroyer,
    kHMLightCruiser,
	kHMHeavyCruiser,
	kHMAircraftCarrier,
	kHMBattleShip,
	kHMSubmarine,
	kHMOtherType,
};

@class HMScreenshotListWindowController;

@interface HMAppDelegate : NSObject <NSApplicationDelegate>

- (void)logLineReturn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (NSPredicate *)predicateForShipType:(HMShipType)shipType;

@property (strong, nonatomic) IBOutlet NSMenuItem *debugMenuItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *billingWindowMenuItem;

@property (readonly) HMFleetInformation *fleetInformation;

@property (nonatomic, strong) NSString *screenShotSaveDirectory;
@property (readonly) HMScreenshotListWindowController *screenshotListWindowController;

- (IBAction)showHideHistory:(id)sender;
- (IBAction)showHideSlotItemWindow:(id)sender;
- (IBAction)showHideUpgradableShipWindow:(id)sender;
- (IBAction)showHideScreenshotListWindow:(id)sender;

- (IBAction)showHidePreferencePanle:(id)sender;

- (IBAction)showWindowAduster:(id)sender;

- (IBAction)saveLocalData:(id)sender;
- (IBAction)loadLocalData:(id)sender;

- (IBAction)openNewBrowser:(id)sender;

#if ENABLE_JSON_LOG
@property (strong) HMJSONViewWindowController *jsonViewWindowController;
#endif

@property (readonly) NSString *appNameForUserAgent;

@end
