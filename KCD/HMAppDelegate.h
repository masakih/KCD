//
//  HMAppDelegate.h
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMJSONViewWindowController.h"

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

@interface HMAppDelegate : NSObject <NSApplicationDelegate>


- (void)logLineReturn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (NSPredicate *)predicateForShipType:(HMShipType)shipType;

@property (strong, nonatomic) IBOutlet NSMenuItem *debugMenuItem;

@property (nonatomic, strong) NSString *screenShotSaveDirectory;

- (IBAction)showHideHistory:(id)sender;
- (IBAction)showHideSlotItemWindow:(id)sender;

- (IBAction)showHidePreferencePanle:(id)sender;

- (IBAction)saveLocalData:(id)sender;
- (IBAction)loadLocalData:(id)sender;

#if ENABLE_JSON_LOG
@property (strong) HMJSONViewWindowController *jsonViewWindowController;
#endif

@end
