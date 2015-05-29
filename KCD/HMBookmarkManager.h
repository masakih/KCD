//
//  HMBookmarkManager.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/27.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMBookmarkItem.h"

@interface HMBookmarkManager : NSObject

@property (readonly, nonatomic) NSArray *bookmarks;

+ (instancetype)sharedManager;

@property (readonly) NSUInteger count;
- (HMBookmarkItem *)bookmarkAtIndex:(NSUInteger)index;

- (void)addBookmark:(HMBookmarkItem *)item;
- (void)insertBookmark:(HMBookmarkItem *)item atIndex:(NSUInteger)index;
- (void)removeBookmark:(HMBookmarkItem *)item;
- (void)removeBookmarkAtIndex:(NSUInteger)index;
- (void)replaceBookmarkAtIndex:(NSUInteger)index withBookmark:(HMBookmarkItem *)item;

@end

@interface NSObject (HMBookmarkMenu)
- (IBAction)selectBookmark:(id)sender;
@end