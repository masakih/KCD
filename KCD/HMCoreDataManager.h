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

- (IBAction)saveAction:(id)sender;

- (NSURL *)applicationFilesDirectory;
- (NSManagedObjectModel *)managedObjectModel;

// for subclass
- (NSString *)modelName;
- (NSString *)storeFileName;
- (NSString *)storeType;
- (NSDictionary *)storeOptions;
- (BOOL)deleteAndRetry;
@end
