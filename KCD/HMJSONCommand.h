//
//  HMJSONCommand.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMJSONCommand : NSObject

+ (HMJSONCommand *)commandForAPI:(NSString *)api;

@property (retain) NSString *argumentsString;
- (void)doCommand:(id)json;

@end
