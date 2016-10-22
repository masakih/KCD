//
//  HMBookmarkItem.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/25.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMBookmarkItem : NSManagedObject <NSPasteboardWriting>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *urlString;
@property NSSize windowContentSize;
@property NSRect contentVisibleRect;
@property BOOL canResize;
@property BOOL canScroll;

@property (nonatomic, strong) NSNumber *order;

/// contentVisibleRectに移動するまでの遅延時間
@property NSTimeInterval scrollDelay;

@end
