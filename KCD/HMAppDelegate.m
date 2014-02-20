//
//  HMAppDelegate.m
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import "HMAppDelegate.h"

#import "HMJSONTracker.h"
#import "HMBroserWindowController.h"


@interface HMAppDelegate ()

@property (retain) HMBroserWindowController *browserWindowController;
@property (retain) HMJSONViewWindowController *logedJSONViewWindowController;
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


//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
//{
//
//}

- (void)awakeFromNib
{
	self.browserWindowController = [HMBroserWindowController new];
	[self.browserWindowController showWindow:nil];
	
	self.jsonViewWindowController = [HMJSONViewWindowController new];
	[self.jsonViewWindowController showWindow:nil];
}

- (IBAction)saveDocument:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setAllowedFileTypes:@[@"plist"]];
	[panel setPrompt:@"Save log"];
	[panel setTitle:@"Sace log"];
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

- (IBAction)openDoument:(id)sender
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

@end
