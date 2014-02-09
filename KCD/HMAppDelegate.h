//
//  HMAppDelegate.h
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>

@interface HMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;


- (void)logLineReturn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);


@end
