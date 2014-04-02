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

/**
 読み出し専用
 */
+ (instancetype)defaultManager;

/**
  編集用
 */
+ (instancetype)oneTimeEditor;

/**
 CoreDataからデータを読み出す
 
 @param entityName 対象エンティティ
 @param predicate 読み出し条件
 @param error エラー
 @return 読み出したデータ
 */
- (NSArray *)objectsWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate error:(NSError **)error;

/**
 CoreDataからデータを読み出す
 
 @param entityName 対象エンティティ
 @param error エラー
 @param format 条件の書式
 @param ... A comma-separated list of arguments to substitute into format.
 @return 読み出したデータ
 */
- (NSArray *)objectsWithEntityName:(NSString *)entityName error:(NSError **)error predicateFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);

- (IBAction)saveAction:(id)sender;

/**
 for subclass
 
 */
/**
 @return 使用するモデル名
 */
- (NSString *)modelName;
/**
 @return ストアファイル名
 */
- (NSString *)storeFileName;
/**
 @return ストアタイプ
 */
- (NSString *)storeType;
/**
 @return ストアオプション
 */
- (NSDictionary *)storeOptions;
/**
 @return モデルが更新されていた時にストアファイルを削除したい時はYESを返す。デフォルトはNO。
 */
- (BOOL)deleteAndRetry;
@end
