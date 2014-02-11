//
//  HMAppDelegate.m
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import "HMAppDelegate.h"
#import "CustomHTTPProtocol.h"

#import "HMJSONTracker.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface HMAppDelegate ()
@property (retain) HMJSONTracker *tracker;
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
	// Insert code here to initialize your application
}

- (void)awakeFromNib
{
	[self.webView setApplicationNameForUserAgent:@"Version/6.0 Safari/536.25"];
	[self.webView setMainFrameURL:@"http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"];
//	[self.webView setMainFrameURL:@"http://www.google.com/"];
	
	
	self.tracker = [HMJSONTracker new];
	
	self.jsonViewWindowController = [HMJSONViewWindowController new];
	[self.jsonViewWindowController showWindow:nil];
}

@end
