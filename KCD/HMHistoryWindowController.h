//
//  HMHistoryWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMHistoryWindowController : NSWindowController <NSTabViewDelegate>

@property (weak) IBOutlet NSArrayController *kaihatuHistoryController;
@property (weak) IBOutlet NSArrayController *kenzoHistoryController;

@property (readonly) NSManagedObjectContext *manageObjectContext;

@property NSInteger selectedTabIndex;

@end
