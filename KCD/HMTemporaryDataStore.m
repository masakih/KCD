//
//  HMTemporaryDataStore.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMTemporaryDataStore.h"

@implementation HMTemporaryDataStore
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self defaultManager];
	});
}

- (NSString *)modelName
{
	return @"Temporary";
}
- (NSString *)storeFileName
{
	return @":memory:";
}
- (NSString *)storeType
{
	return NSInMemoryStoreType;
}
- (NSDictionary *)storeOptions
{
//	NSDictionary *options = @{
//#if COREDATA_STORE_TYPE == 0
//							  NSSQLitePragmasOption : @{@"journal_mode" : @"MEMORY"},
//#endif
//							  NSMigratePersistentStoresAutomaticallyOption : @YES,
//							  NSInferMappingModelAutomaticallyOption : @YES
//							  };
//	return options;
	return nil;
}
- (BOOL)deleteAndRetry
{
	return YES;
}
@end
