//
//  HMJSONCommand.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMAPIResult.h"


@interface HMJSONCommand : NSObject

+ (HMJSONCommand *)commandForAPIResult:(HMAPIResult *)apiResult;

@property (copy) NSString *argumentsString;
@property (strong) NSData *jsonData;
@property (strong) NSDate *recieveDate;

- (void)execute;


// for subclass
+ (void)registerClass:(Class)commandClass;

@property (copy, readonly) NSString *api;	// api is /kcsapi/mainAPI/subAPI
@property (strong, readonly) NSDictionary *arguments;
@property (strong, readonly) id json;		// NSArray or NSDictionary

#if ENABLE_JSON_LOG
@property (strong, readonly) NSArray *jsonTree;	// for NSTreeController
@property (strong, readonly) NSArray *argumentArray; // for NSArrayController
#endif

+ (BOOL)canExcuteAPI:(NSString *)api;

@property (readonly) NSString *primaryKey;
@property (readonly) NSArray *ignoreKeys;
@property (readonly) NSString *dataKey;

- (void)commitJSONToEntityNamed:(NSString *)entityName;

- (void)registerElement:(NSDictionary *)element
			   toObject:(NSManagedObject *)object;

// 特別な処理を行う
// 登録前処理
- (void)beginRegisterObject:(NSManagedObject *)object;
// default return NO
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object;

// データ登録後の処理を行う
- (void)finishOperating:(NSManagedObjectContext *)moc;

- (void)setValueIfNeeded:(id)value toObject:(id)object forKey:(NSString *)key;

NSString *keyByDeletingPrefix(NSString *key);

- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
