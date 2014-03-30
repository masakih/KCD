//
//  HMCoreDataManager.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMCoreDataManager : NSObject

@property (readonly) NSManagedObjectContext *managedObjectContext;

+ (instancetype)defaultManager;
+ (instancetype)oneTimeEditor;

- (NSArray *)objectsWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate error:(NSError **)error;
- (NSArray *)objectsWithEntityName:(NSString *)entityName error:(NSError **)error predicateFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);

- (IBAction)saveAction:(id)sender;

// for subclass
- (NSString *)modelName;
- (NSString *)storeFileName;
- (NSString *)storeType;
- (NSDictionary *)storeOptions;
- (BOOL)deleteAndRetry;
@end
