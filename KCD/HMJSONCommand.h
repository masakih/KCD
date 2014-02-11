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

@property (copy) NSString *argumentsString;
@property (retain) NSData *jsonData;

- (void)execute;


// for subclass
@property (copy, readonly) NSString *api;
@property (retain, readonly) NSArray *arguments;
@property (retain, readonly) id json;		// NSArray or NSDictionary
@property (retain, readonly) NSArray *jsonTree;	// for NSTreeController


+ (BOOL)canExcuteAPI:(NSString *)api;
+ (void)registerClass:(Class)commandClass;

@end
