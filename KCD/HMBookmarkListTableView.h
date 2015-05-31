//
//  HMBookmarkListTableView.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/31.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMBookmarkListTableView : NSTableView

@end

@protocol HMBookmarkListTableViewDatasorce <NSObject>

@optional
- (NSMenu *)tableView:(HMBookmarkListTableView *)tableView menuForEvent:(NSEvent *)event;

@end
