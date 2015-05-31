//
//  HMBookmarkListViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/30.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMBookMarkItem.h"

@protocol HMBookmarkListViewControllerDelegate;


@interface HMBookmarkListViewController : NSViewController

@property (weak) id<HMBookmarkListViewControllerDelegate> delegate;

@end

@protocol HMBookmarkListViewControllerDelegate <NSObject>

- (void)didSelectBookmark:(HMBookmarkItem *)bookmark;

@end
