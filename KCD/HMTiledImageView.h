//
//  HMTiledImageView.h
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/05/02.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HMTiledImageView : NSView

@property (readonly) NSImage *image;
@property (nonatomic, copy) NSArray<NSImage *> *images;

@property (nonatomic) NSInteger columnCount;

@end
