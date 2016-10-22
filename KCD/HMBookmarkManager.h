//
//  HMBookmarkManager.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/27.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMBookmarkItem.h"
#import "HMBookmarkDataStore.h"

@interface HMBookmarkManager : NSObject

@property (readonly) NSArray *bookmarks;

+ (instancetype)sharedManager;

@property (readonly) NSManagedObjectContext *manageObjectContext;
- (HMBookmarkItem *)createNewBookmark;

- (HMBookmarkDataStore *)editorStore;

@end

@interface NSObject (HMBookmarkMenu)
- (IBAction)selectBookmark:(id)sender;
@end
