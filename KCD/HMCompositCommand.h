//
//  HMCompositCommand.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/14.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONCommand.h"

#ifdef DEBUG
@interface HMCompositCommand : HMJSONCommand

+ (id)compositCommandWithCommands:(HMJSONCommand *)cmd1, ...;

@end
#endif