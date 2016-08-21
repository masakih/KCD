//
//  HMScreenshotListWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/11/03.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class HMMaskSelectView;

@interface HMScreenshotListWindowController : NSWindowController

- (void)registerScreenshot:(NSBitmapImageRep *)image fromOnScreen:(NSRect)screenRect;

@end
