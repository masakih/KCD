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

#import "HMTSVSupport.h"


#ifdef DEBUG
#import "HMShipWindowController.h"
#endif

//@interface NSObject (HMM_NSUserNotificationCenterPrivateMethods)
//- (void)_removeDisplayedNotification:(id)obj;
//@end

@interface HMAppDelegate () <NSUserNotificationCenterDelegate>

@property (strong) HMBroserWindowController *browserWindowController;
@property (strong) HMHistoryWindowController *historyWindowController;
@property (strong) HMSlotItemWindowController *slotItemWindowController;
@property (strong) HMPreferencePanelController *preferencePanelController;

#ifdef DEBUG
@property (strong) HMShipWindowController *shipWindowController;
#endif
#if ENABLE_JSON_LOG
@property (strong) HMJSONViewWindowController *logedJSONViewWindowController;
#endif
@end

@implementation HMAppDelegate

static FILE* logFileP = NULL;

+ (void)initialize
{
	NSString *fullpath = [NSHomeDirectory() stringByAppendingPathComponent:@"kcd.log"];
	logFileP = fopen([fullpath fileSystemRepresentation], "a");
}

- (void)logLineReturn:(NSString *)format, ...
{
	@synchronized (self) {
		va_list ap;
		va_start(ap, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
		fprintf(logFileP, "%s\n", [str UTF8String]);
		fflush(logFileP);
		va_end(ap);
	}
}
- (void)log:(NSString *)format, ...
{
	@synchronized (self) {
		va_list ap;
		va_start(ap, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
		fprintf(logFileP, "%s", [str UTF8String]);
		fflush(logFileP);
		va_end(ap);
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	[unc setDelegate:self];
	
	NSURLCache *cache = [NSURLCache sharedURLCache];
	[cache setDiskCapacity:1024 * 1024 * 1024];
//	[cache setMemoryCapacity:1024];
}

- (void)awakeFromNib
{
	self.browserWindowController = [HMBroserWindowController new];
	[self.browserWindowController showWindow:nil];
	
#if ENABLE_JSON_LOG
	self.jsonViewWindowController = [HMJSONViewWindowController new];
	[self.jsonViewWindowController showWindow:nil];
#endif
#ifdef DEBUG
	self.shipWindowController = [HMShipWindowController new];
	[self.shipWindowController showWindow:nil];
#endif
	if(!HMStandardDefaults.showsDebugMenu) {
		[self.debugMenuItem setHidden:YES];
	}
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
		path = [[self documentsFilesDirectory] path];
	}
	
	return path;
}
- (NSURL *)documentsFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	return [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
	} else if(action == @selector(saveLocalData:) || action == @selector(loadLocalData:)) {
		return YES;
	} else if(action == @selector(showHidePreferencePanle:)) {
		return YES;
	}
#if ENABLE_JSON_LOG
	else if(action == @selector(saveDocument:) || action == @selector(openDocument:)) {
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
		if(result == NSOKButton) {
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
		if(result == NSOKButton) {
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
