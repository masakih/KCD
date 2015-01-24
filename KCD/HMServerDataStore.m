//
//  HMServerDataStore.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMServerDataStore.h"

@implementation HMServerDataStore
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self defaultManager];
	});
}

- (NSString *)modelName
{
	return @"KCD";
}
- (NSString *)storeFileName
{
#if COREDATA_STORE_TYPE == 0
	return @"KCD.storedata";
#else
	return @"KCD.storedata.xml";
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
#if COREDATA_STORE_TYPE == 0
							  NSSQLitePragmasOption : @{@"journal_mode" : @"MEMORY"},
#endif
							  NSMigratePersistentStoresAutomaticallyOption : @YES,
							  NSInferMappingModelAutomaticallyOption : @YES
							  };
	return options;
}
- (BOOL)deleteAndRetry
{
	return YES;
}
@end
