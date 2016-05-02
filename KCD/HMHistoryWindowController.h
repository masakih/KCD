//
//  HMHistoryWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMHistoryWindowController : NSWindowController <NSTabViewDelegate>

@property (strong) IBOutlet NSArrayController *kaihatuHistoryController;
@property (strong) IBOutlet NSArrayController *kenzoHistoryController;
@property (strong) IBOutlet NSArrayController *dropHistoryController;

@property (readonly) NSManagedObjectContext *manageObjectContext;

@property NSInteger selectedTabIndex;

@end
