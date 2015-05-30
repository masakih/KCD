//
//  HMBookmarkItem.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/25.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMBookmarkItem : NSManagedObject

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *urlString;
@property NSSize windowContentSize;
@property NSRect contentVisibleRect;
@property BOOL canResize;
@property BOOL canScroll;

@property (strong, nonatomic) NSNumber *order;

/// contentVisibleRectに移動するまでの遅延時間
@property NSTimeInterval scrollDelay;

@end
