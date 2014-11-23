//
//  HMExternalBrowserWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/11/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>


@interface HMExternalBrowserWindowController : NSWindowController


@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *goSegment;

- (IBAction)clickGoBackSegment:(id)sender;

@end
