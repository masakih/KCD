//
//  HMLocalDataStore.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMLocalDataStore.h"

@implementation HMLocalDataStore

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self defaultManager];
	});
}
- (NSString *)modelName
{
	return @"LocalData";
}
- (NSString *)storeFileName
{
#if COREDATA_STORE_TYPE == 0
	return @"LocalData.storedata";
#else
	return @"LocalData.storedata.xml";
#endif
}
- (NSString *)storeType
{
#if COREDATA_STORE_TYPE == 0
	return NSSQLiteStoreType;
#else
	return NSXMLStoreType;
#endif
}
- (NSDictionary *)storeOptions
{
	NSDictionary *options = @{
							  NSMigratePersistentStoresAutomaticallyOption : @YES,
							  NSInferMappingModelAutomaticallyOption : @YES
							  };
	return options;
}
- (BOOL)deleteAndRetry
{
	return NO;
}

@end
