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
+ (void)registerClass:(Class)commandClass;

@property (copy, readonly) NSString *api;	// api is /kcsapi/mainAPI/subAPI
NSString *mainAPI(NSString *api);
NSString *subAPI(NSString *api);
@property (retain, readonly) NSArray *arguments;
@property (retain, readonly) id json;		// NSArray or NSDictionary
@property (retain, readonly) NSArray *jsonTree;	// for NSTreeController

+ (BOOL)canExcuteAPI:(NSString *)api;


// default return NO
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object;


NSString *keyByDeletingPrefix(NSString *key);

- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
