//
//  HMJSONViewWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMJSONViewWindowController : NSWindowController
@property (nonatomic, weak) IBOutlet NSTableView *argumentsView;
@property (nonatomic, weak) IBOutlet NSOutlineView *jsonView;

@property (nonatomic, weak) IBOutlet NSArrayController *apis;


@property (weak) NSArray *arguments;
@property (strong, readonly) NSMutableArray *commands;
@property (weak, readonly) id json;

- (void)setCommand:(NSDictionary *)command;

- (void)setCommandArray:(NSArray *)commands;


- (IBAction)clearLog:(id)sender;


@end
