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

#import "HMExternalBrowserWindowController.h"
#import "HMBrowserContentAdjuster.h"

#import "HMTSVSupport.h"

#import "CustomHTTPProtocol.h"


#ifdef DEBUG
#import "HMShipWindowController.h"
#import "HMEquipmentWindowController.h"
#import "HMMapWindowController.h"

#import "HMFleetInformation.h"

#import "HMUITestWindowController.h"
#endif

#ifndef UI_TEST
#	define UI_TEST 1
#endif

//@interface NSObject (HMM_NSUserNotificationCenterPrivateMethods)
//- (void)_removeDisplayedNotification:(id)obj;
//@end

@interface HMAppDelegate () <NSUserNotificationCenterDelegate>

@property (strong) HMBroserWindowController *browserWindowController;
@property (strong) HMHistoryWindowController *historyWindowController;
@property (strong) HMSlotItemWindowController *slotItemWindowController;
@property (strong) HMPreferencePanelController *preferencePanelController;
@property (strong) HMUpgradableShipsWindowController *upgradableShipWindowController;

//@property (strong) HMExternalBrowserWindowController *externalBrowserWindowController;
@property (strong) HMBrowserContentAdjuster *browserContentAdjuster;

@property (strong) NSMutableArray *browserWindowControllers;

@property (strong) NSMutableArray *updaters;

#ifdef DEBUG
@property (strong) HMShipWindowController *shipWindowController;
@property (strong) HMShipMasterDetailWindowController *shipMDWindowController;
@property (strong) HMEquipmentWindowController *equipmentWindowController;
@property (strong) HMMapWindowController *mapWindowController;
#endif

#if UI_TEST
@property (strong) HMUITestWindowController *uiTestWindowController;
#endif
#if ENABLE_JSON_LOG
@property (strong) HMJSONViewWindowController *logedJSONViewWindowController;
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
	return @"Version/8.0.8 Safari/600.8.9";
}

#ifdef DEBUG
- (HMFleetInformation *)fleetInformation
{
	static HMFleetInformation *_fleetInformation = nil;
	if(_fleetInformation) return _fleetInformation;
	_fleetInformation = [HMFleetInformation new];
	return _fleetInformation;
}
#endif

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
		[self.browserWindowControllers removeObject:object];
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
