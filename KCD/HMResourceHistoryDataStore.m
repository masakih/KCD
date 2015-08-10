//
//  HMResourceHistoryDataStore.m
//  KCD
//
//  Created by Hori,Masaki on 2015/08/03.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMResourceHistoryDataStore.h"

@implementation HMResourceHistoryDataStore
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self defaultManager];
	});
}
- (NSString *)modelName
{
	return @"ResourceHistory";
}
- (NSString *)storeFileName
{
	return @"ResourceHistory.storedata";
}
- (NSString *)storeType
{
	return NSSQLiteStoreType;
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
