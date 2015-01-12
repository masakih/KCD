//
//  HMCompositCommand.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/14.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONCommand.h"

@interface HMCompositCommand : HMJSONCommand

@property (readonly) NSArray *commands;


+ (id)compositCommandWithCommands:(HMJSONCommand *)cmd1, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithCommands:(HMJSONCommand *)cmd1, ...;

/// for Swift
- (id)initWithCommandArray:(NSArray *)commadArray;

@end
