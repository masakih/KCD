//
//  HMJSONViewWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef DEBUG

@interface HMJSONViewWindowController : NSWindowController

@property (nonatomic, strong, readonly) NSMutableArray *commands;

- (void)setCommand:(NSDictionary *)command;

- (void)setCommandArray:(NSArray *)commands;


- (IBAction)clearLog:(id)sender;


@end

#endif
