//
//  HMScreenshotCollectionViewItem.h
//  CollectionViewTest
//
//  Created by Hori,Masaki on 2016/10/09.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface HMScreenshotCollectionViewItem : NSCollectionViewItem <QLPreviewItem>

@property (readonly) NSRect imageFrame;

@end
