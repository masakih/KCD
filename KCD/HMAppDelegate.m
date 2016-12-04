//
//  HMAppDelegate.m
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import "HMAppDelegate.h"

#import "HMUserDefaults.h"
#import "HMBroserWindowController.h"
#import "HMHistoryWindowController.h"
#import "HMSlotItemWindowController.h"
#import "HMPreferencePanelController.h"
#import "HMUpgradableShipsWindowController.h"
#import "HMScreenshotListWindowController.h"
#import "HMShipMasterDetailWindowController.h"
#import "HMAirBaseWindowController.h"


#import "HMExternalBrowserWindowController.h"
#import "HMBrowserContentAdjuster.h"

#import "HMFleetManager.h"

#import "HMPeriodicNotifier.h"
#import "HMHistoryItemCleaner.h"

#import "HMTSVSupport.h"

#import "CustomHTTPProtocol.h"


#ifdef DEBUG
#import "HMShipWindowController.h"
#import "HMEquipmentWindowController.h"
#import "HMMapWindowController.h"

#import "HMUITestWindowController.h"
#endif

#ifndef UI_TEST
#	define UI_TEST 1
#endif

//@interface NSObject (HMM_NSUserNotificationCenterPrivateMethods)
//- (void)_removeDisplayedNotification:(id)obj;
//@end

@interface HMAppDelegate () <NSUserNotificationCenterDelegate>

@property (nonatomic, strong) HMBroserWindowController *browserWindowController;
@property (nonatomic, strong) HMHistoryWindowController *historyWindowController;
@property (nonatomic, strong) HMSlotItemWindowController *slotItemWindowController;
@property (nonatomic, strong) HMPreferencePanelController *preferencePanelController;
@property (nonatomic, strong) HMUpgradableShipsWindowController *upgradableShipWindowController;
@property (nonatomic, strong) HMAirBaseWindowController *airBaseWindowController;

//@property (strong) HMExternalBrowserWindowController *externalBrowserWindowController;
@property (nonatomic, strong) HMBrowserContentAdjuster *browserContentAdjuster;

@property (nonatomic, strong) NSMutableArray *browserWindowControllers;

@property (nonatomic, strong) NSMutableArray *updaters;

@property (nonatomic, strong) HMFleetManager *fleetManager;

@property (nonatomic, strong) HMPeriodicNotifier *historyCleanNotifer;

#ifdef DEBUG
@property (nonatomic, strong) HMShipWindowController *shipWindowController;
@property (nonatomic, strong) HMShipMasterDetailWindowController *shipMDWindowController;
@property (nonatomic, strong) HMEquipmentWindowController *equipmentWindowController;
@property (nonatomic, strong) HMMapWindowController *mapWindowController;
#endif

#if UI_TEST
@property (nonatomic, strong) HMUITestWindowController *uiTestWindowController;
#endif
#if ENABLE_JSON_LOG
@property (nonatomic, strong) HMJSONViewWindowController *logedJSONViewWindowController;
#endif
@end

@implementation HMAppDelegate

@synthesize screenshotListWindowController = _screenshotListWindowController;

- (void)logLineReturn:(NSString *)format, ...
{
	@synchronized (self) {
		va_list ap;
		va_start(ap, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
		fprintf(stderr, "%s\n", [str UTF8String]);
		va_end(ap);
	}
}
- (void)log:(NSString *)format, ...
{
	@synchronized (self) {
		va_list ap;
		va_start(ap, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
		fprintf(stderr, "%s", [str UTF8String]);
		va_end(ap);
	}
}

- (instancetype)init
{
	self = [super init];
	if(self) {
		self.updaters = [NSMutableArray new];
		_fleetManager = [HMFleetManager new];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[CustomHTTPProtocol setupCache];
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	[unc setDelegate:self];
	
	self.browserWindowControllers = [NSMutableArray new];
	
	[NSTimer scheduledTimerWithTimeInterval:0.33
									 target:self
								   selector:@selector(fire:)
								   userInfo:nil
									repeats:YES];
}

- (void)awakeFromNib
{
	self.browserWindowController = [HMBroserWindowController new];
	[self.browserWindowController showWindow:nil];
	
#if ENABLE_JSON_LOG
	self.jsonViewWindowController = [HMJSONViewWindowController new];
	[self.jsonViewWindowController showWindow:nil];
#endif

#if UI_TEST
	self.uiTestWindowController = [HMUITestWindowController new];
	[self.uiTestWindowController showWindow:nil];
#endif
	if(!HMStandardDefaults.showsDebugMenu) {
		[self.debugMenuItem setHidden:YES];
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	_historyCleanNotifer = [HMPeriodicNotifier periodicNotifierWithHour:0 minutes:7];
	[nc addObserverForName:HMPeriodicNotification
					object:_historyCleanNotifer
					 queue:nil
				usingBlock:^(NSNotification * _Nonnull note) {
					HMHistoryItemCleaner *historyItemCleaner = [HMHistoryItemCleaner new];
					[historyItemCleaner cleanOldHistoryItems];
				}];
}

- (void)addCounterUpdateBlock:(void(^)())updater
{
	[self.updaters addObject:updater];
}
- (void)fire:(NSTimer *)timer
{
	for(void (^updater)() in self.updaters) {
		updater();
	}
}

- (void)clearCache
{
	[CustomHTTPProtocol clearCache];
}

- (HMScreenshotListWindowController *)screenshotListWindowController
{
	if(_screenshotListWindowController) return _screenshotListWindowController;
	_screenshotListWindowController = [HMScreenshotListWindowController new];
	return _screenshotListWindowController;
}

- (NSArray *)shipTypeCategories
{
	static NSArray *categories = nil;
	
	if(categories) return categories;
	
	categories = @[
				   @[@(0)],	// dummy
				   @[@2],	// destoryer
				   @[@3, @4],	// leght cruiser
				   @[@5,@6],	// heavy crusier
				   @[@7, @11, @16, @18],	// aircraft carrier
				   @[@8, @9, @10, @12],	// battle ship
				   @[@13, @14],	// submarine
				   @[@1, @15, @17, @19]
				   ];
	return categories;
}
- (NSPredicate *)predicateForShipType:(HMShipType)shipType
{
	NSPredicate *predicate = nil;
	NSArray *categories = [self shipTypeCategories];
	switch (shipType) {
		case kHMAllType:
			predicate = nil;
			break;
		case kHMDestroyer:
		case kHMLightCruiser:
		case kHMHeavyCruiser:
		case kHMAircraftCarrier:
		case kHMBattleShip:
		case kHMSubmarine:
			predicate = [NSPredicate predicateWithFormat:@"master_ship.stype.id IN %@", categories[shipType]];
			break;
			
		case kHMOtherType:
		{
			NSMutableArray *ommitTypes = [NSMutableArray new];
			for(int i = kHMDestroyer; i < kHMOtherType; i++) {
				[ommitTypes addObjectsFromArray:categories[i]];
			}
			predicate = [NSPredicate predicateWithFormat:@"NOT master_ship.stype.id IN %@", ommitTypes];
		}
			break;
	}
	
	return predicate;
}

- (void)setScreenShotSaveDirectory:(NSString *)screenShotSaveDirectory
{
	HMStandardDefaults.screenShotSaveDirectory = screenShotSaveDirectory;
}
- (NSString *)screenShotSaveDirectory
{
	NSString *path = HMStandardDefaults.screenShotSaveDirectory;
	if(!path) {
		path = [[self picturesDirectory] path];
	}
	
	return path;
}
- (NSURL *)documentsFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	return [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSURL *)picturesDirectory
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [[fileManager URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSURL *)supportDirectory
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSURL *ownAppSuportURL = [appSupportURL URLByAppendingPathComponent:@"com.masakih.KCD"];
	return ownAppSuportURL;
}


- (NSString *)appNameForUserAgent
{
	return @"Version/9.1.2 Safari/601.7.7";
}

- (NSFont *)monospaceSystemFont11
{
	NSFont *font11 = nil;
	if([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
		font11 = [NSFont monospacedDigitSystemFontOfSize:11 weight:NSFontWeightRegular];
	} else {
		font11 = [NSFont systemFontOfSize:11];
	}
	
	return font11;
}
- (NSFont *)monospaceSystemFont12
{
	NSFont *font12 = nil;
	if([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
		font12 = [NSFont monospacedDigitSystemFontOfSize:12 weight:NSFontWeightRegular];
	} else {
		font12 = [NSFont systemFontOfSize:12];
	}
	
	return font12;
}
- (NSFont *)monospaceSystemFont13
{
	NSFont *font13 = nil;
	if([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
		font13 = [NSFont monospacedDigitSystemFontOfSize:13 weight:NSFontWeightRegular];
	} else {
		font13 = [NSFont systemFontOfSize:13];
	}
	
	return font13;
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	if(action == @selector(showHideHistory:)) {
		NSWindow *window = self.historyWindowController.window;
		if(!window.isVisible || !window.isMainWindow) {
			[menuItem setTitle:NSLocalizedString(@"Show History", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Hide History", @"")];
		}
		return YES;
	} else if(action == @selector(showHideSlotItemWindow:)) {
		NSWindow *window = self.slotItemWindowController.window;
		if(!window.isVisible || !window.isMainWindow) {
			[menuItem setTitle:NSLocalizedString(@"Show Slot Item", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Hide Slot Item", @"")];
		}
		return YES;
	} else if(action == @selector(showHideUpgradableShipWindow:)) {
		NSWindow *window = self.upgradableShipWindowController.window;
		if(!window.isVisible || !window.isMainWindow) {
			[menuItem setTitle:NSLocalizedString(@"Show Upgradable Ships", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Hide Upgradable Ships", @"")];
		}
		return YES;
    } else if(action == @selector(showHideScreenshotListWindow:)) {
        NSWindow *window = self.screenshotListWindowController.window;
        if(!window.isVisible || !window.isMainWindow) {
            [menuItem setTitle:NSLocalizedString(@"Show Screenshot List", @"")];
        } else {
            [menuItem setTitle:NSLocalizedString(@"Hide Screenshot List", @"")];
        }
        return YES;
    } else if(action == @selector(showHideAirBaseInfoWindow:)) {
        NSWindow *window = self.airBaseWindowController.window;
        if(!window.isVisible || !window.isMainWindow) {
            [menuItem setTitle:NSLocalizedString(@"Show Air Base Info", @"")];
        } else {
            [menuItem setTitle:NSLocalizedString(@"Hide Air Base Info", @"")];
        }
        return YES;
    } else if(action == @selector(saveLocalData:) || action == @selector(loadLocalData:)) {
		return YES;
	} else if(action == @selector(showHidePreferencePanle:)) {
		return YES;
	} else if(action == @selector(openNewBrowser:) || action == @selector(selectBookmark:)) {
		return YES;
	} else if(action == @selector(showWindowAduster:)) {
		return YES;
	}
#if ENABLE_JSON_LOG
	else if(action == @selector(saveDocument:) || action == @selector(openDocument:)) {
		return YES;
	} else if(action == @selector(removeDatabaseFile:)) {
		return YES;
	}
#endif
#ifdef DEBUG
	else if(action == @selector(showShipWindow:) || action == @selector(showEquipmentWindow:)
			|| action == @selector(showMapWindow:) || action == @selector(showOwnershipShipWindow:) ) {
		return YES;
	}
#endif
	return NO;
}

- (IBAction)showHideHistory:(id)sender
{
	if(!self.historyWindowController) {
		self.historyWindowController = [HMHistoryWindowController new];
	}
	
	NSWindow *window = self.historyWindowController.window;
	if(!window.isVisible || !window.isMainWindow) {
		[window makeKeyAndOrderFront:nil];
	} else {
		[window orderOut:nil];
	}
}

- (IBAction)showHideSlotItemWindow:(id)sender
{
	if(!self.slotItemWindowController) {
		self.slotItemWindowController = [HMSlotItemWindowController new];
	}
	
	NSWindow *window = self.slotItemWindowController.window;
	if(!window.isVisible || !window.isMainWindow) {
		[window makeKeyAndOrderFront:nil];
	} else {
		[window orderOut:nil];
	}
}

- (IBAction)showHidePreferencePanle:(id)sender
{
	if(!self.preferencePanelController) {
		self.preferencePanelController = [HMPreferencePanelController new];
	}
	
	NSWindow *window = self.preferencePanelController.window;
	if(!window.isVisible || !window.isMainWindow) {
		[window makeKeyAndOrderFront:nil];
	} else {
		[window orderOut:nil];
	}
}

- (IBAction)showHideUpgradableShipWindow:(id)sender
{
	if(!self.upgradableShipWindowController) {
		self.upgradableShipWindowController = [HMUpgradableShipsWindowController new];
	}
	
	NSWindow *window = self.upgradableShipWindowController.window;
	if(!window.isVisible || !window.isMainWindow) {
		[window makeKeyAndOrderFront:nil];
	} else {
		[window orderOut:nil];
	}
}

- (IBAction)showHideScreenshotListWindow:(id)sender
{
	NSWindow *window = self.screenshotListWindowController.window;
	if(!window.isVisible || !window.isMainWindow) {
		[window makeKeyAndOrderFront:nil];
	} else {
		[window orderOut:nil];
	}
}
- (IBAction)showHideAirBaseInfoWindow:(id)sender
{
    if(!self.airBaseWindowController) {
        self.airBaseWindowController = [HMAirBaseWindowController new];
    }
    
    NSWindow *window = self.airBaseWindowController.window;
    if(!window.isVisible || !window.isMainWindow) {
        [window makeKeyAndOrderFront:nil];
    } else {
        [window orderOut:nil];
    }
}

- (IBAction)openNewBrowser:(id)sender
{
	[self createNewBrowser];
}
- (IBAction)selectBookmark:(id)sender
{
	HMExternalBrowserWindowController *browser = [self createNewBrowser];
	
	[browser selectBookmark:sender];
}
- (HMExternalBrowserWindowController *)createNewBrowser
{
	HMExternalBrowserWindowController *browser = [HMExternalBrowserWindowController new];
	[self.browserWindowControllers addObject:browser];
	[browser.window makeKeyAndOrderFront:nil];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(windowWillClose:)
			   name:NSWindowWillCloseNotification
			 object:browser.window];
	
	return browser;
}
- (IBAction)showWindowAduster:(id)sender
{
	if(! self.browserContentAdjuster) {
		self.browserContentAdjuster = [HMBrowserContentAdjuster new];
	}
	[self.browserContentAdjuster showWindow:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
	id object = [notification object];
	if([self.browserWindowControllers containsObject:object]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSWindowWillCloseNotification
													  object:object];
		[self.browserWindowControllers removeObject:object];
	}
}

- (IBAction)removeDatabaseFile:(id)sender
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *appleScriptPath = [mainBundle pathForResource:@"RemoveDatabaseFileAndRestart"
													 ofType:@"app"];
	NSTask *task = [NSTask new];
	task.launchPath = @"/usr/bin/open";
	task.arguments = @[appleScriptPath];
	[task launch];
}

#ifdef DEBUG

- (IBAction)showShipWindow:(id)sender
{
	if(!_shipWindowController) {
		self.shipWindowController = [HMShipWindowController new];
	}
	[self.shipWindowController showWindow:nil];
}
- (IBAction)showEquipmentWindow:(id)sender
{
	if(!_equipmentWindowController) {
		self.equipmentWindowController = [HMEquipmentWindowController new];
	}
	[self.equipmentWindowController showWindow:nil];
}
- (IBAction)showMapWindow:(id)sender
{
	if(!_mapWindowController) {
		self.mapWindowController = [HMMapWindowController new];
	}
	[self.mapWindowController showWindow:nil];
}
- (IBAction)showOwnershipShipWindow:(id)sender
{
	if(!_shipMDWindowController) {
		self.shipMDWindowController = [HMShipMasterDetailWindowController new];
	}
	[self.shipMDWindowController showWindow:nil];
}
#endif

#pragma mark - NSApplicationDelegate
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

#pragma mark - NSUserNotificationCenterDelegate
//- (void)removeUserNotification:(NSDictionary *)dict
//{
//	NSUserNotificationCenter *center = [dict objectForKey:@"center"];
//	NSUserNotification *notification = [dict objectForKey:@"notification"];
//	[center removeDeliveredNotification:notification];
//	//	[center _removeDisplayedNotification:notification];
//}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;
}

//- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
//{
//	[self performSelector:@selector(removeUserNotification:)
//			   withObject:@{@"center":center, @"notification":notification}
//			   afterDelay:3];
//}
//- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
//{
//	[center removeDeliveredNotification:notification];
//}
#if ENABLE_JSON_LOG
- (IBAction)saveDocument:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setAllowedFileTypes:@[@"plist"]];
	[panel setPrompt:@"Save log"];
	[panel setTitle:@"Save log"];
	[panel beginWithCompletionHandler:^(NSInteger result) {
		if(result == NSModalResponseOK) {
			NSArray *array = [self.jsonViewWindowController.commands copy];
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
			if(!data) {
				NSLog(@"can not convert log.");
				return;
			}
			NSError *error = nil;
			[data writeToURL:panel.URL
					 options:NSDataWritingAtomic
					   error:&error];
			if(error) {
				NSLog(@"can not save property list.: %@", error);
			}
		}
	}];
}

- (IBAction)openDocument:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowedFileTypes:@[@"plist"]];
	[panel setAllowsMultipleSelection:NO];
	[panel setPrompt:@"Open log"];
	[panel setTitle:@"Open log"];
	[panel beginWithCompletionHandler:^(NSInteger result) {
		if(result == NSModalResponseOK) {
			NSData *data = [NSData dataWithContentsOfURL:panel.URL];
			id array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			if(!array || ![array isKindOfClass:[NSArray class]]) {
				NSLog(@"Can not convert data to log.");
				return;
			}
			
			self.logedJSONViewWindowController = [HMJSONViewWindowController new];
			[self.logedJSONViewWindowController setCommandArray:array];
			[[self.logedJSONViewWindowController window] setTitle:@"SAVED LOG FILE VIEWER"];
			
			[self.logedJSONViewWindowController showWindow:nil];
		}
	}];
}
#endif

- (IBAction)saveLocalData:(id)sender
{
	[[HMTSVSupport new] save:sender];
}
- (IBAction)loadLocalData:(id)sender
{
	[[HMTSVSupport new] load:sender];
}

@end
