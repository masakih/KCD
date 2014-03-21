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
@property (strong) NSData *jsonData;
@property (strong) NSDate *recieveDate;

- (void)execute;


// for subclass
+ (void)registerClass:(Class)commandClass;

@property (copy, readonly) NSString *api;	// api is /kcsapi/mainAPI/subAPI
@property (strong, readonly) NSArray *arguments;
@property (strong, readonly) id json;		// NSArray or NSDictionary
@property (strong, readonly) NSArray *jsonTree;	// for NSTreeController

+ (BOOL)canExcuteAPI:(NSString *)api;

@property (readonly) NSArray *ignoreKeys;

- (void)commitJSONToEntityNamed:(NSString *)entityName;

// 特別な処理を行う
// default return NO
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object;

// データ登録後の処理を行う
- (void)finishOperating:(NSManagedObjectContext *)moc;

NSString *keyByDeletingPrefix(NSString *key);

- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
