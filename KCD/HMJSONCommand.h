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

- (void)doCommand:(id)json;

@property (copy) NSString *argumentsString;
@property (retain) NSArray *arguments;
@property (copy, readonly) NSString *api;
@property (retain) id json;


// for subclass
+ (BOOL)canExcuteAPI:(NSString *)api;

+ (void)registerClass:(Class)commandClass;

@end
