//
//  HMAppDelegate.m
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import "HMAppDelegate.h"

#import "HMBroserWindowController.h"
#import "HMHistoryWindowController.h"


#ifdef DEBUG
#import "HMShipWindowController.h"

#import "HMTSVSupport.h"
#endif

//@interface NSObject (HMM_NSUserNotificationCenterPrivateMethods)
//- (void)_removeDisplayedNotification:(id)obj;
//@end

@interface HMAppDelegate () <NSUserNotificationCenterDelegate>

@property (strong) HMBroserWindowController *browserWindowController;
@property (strong) HMHistoryWindowController *historyWindowController;

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
#else
	NSMenu *mainMenu = [NSApp mainMenu];
	NSInteger debugMenuIndex = [mainMenu indexOfItemWithTag:1000];
	[mainMenu removeItemAtIndex:debugMenuIndex];
#endif
}

- (NSArray *)shipTypeCategories
{
	static NSArray *categories = nil;
	
	if(categories) return categories;
	
	categories = @[
				   @[@2],
				   @[@3, @4],
				   @[@5,@6],
				   @[@7, @11, @16, @18],
				   @[@8, @9, @10, @12],
				   @[@13, @14],
				   @[@1, @15, @17]
				   ];
	return categories;
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

#ifdef DEBUG
- (IBAction)saveLocalData:(id)sender
{
	[[HMTSVSupport new] save:sender];
}
- (IBAction)loadLocalData:(id)sender
{
	[[HMTSVSupport new] load:sender];
}
#endif

@end
