//
//  HMJSONViewWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMJSONViewWindowController : NSWindowController
@property (nonatomic, assign) IBOutlet NSTableView *argumentsView;
@property (nonatomic, assign) IBOutlet NSOutlineView *jsonView;

@property (nonatomic, assign) IBOutlet NSArrayController *apis;


@property (assign) NSArray *arguments;
@property (retain, readonly) NSMutableArray *commands;
@property (assign, readonly) id json;

- (void)setCommand:(NSDictionary *)command;

- (void)setCommandArray:(NSArray *)commands;


@end
