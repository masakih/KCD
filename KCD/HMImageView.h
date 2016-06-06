//
//  HMImageView.h
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/05/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMImageView : NSView
@property (nonatomic, copy) NSArray<NSImage *> *images;

@property (nonatomic, readonly) NSRect imageRect;
@end
