//
//  HMBroserWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>


@interface HMBroserWindowController : NSWindowController

@property (assign) IBOutlet WebView *webView;

@end
