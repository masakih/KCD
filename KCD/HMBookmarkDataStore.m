//
//  HMBookmarkDataStore.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/29.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkDataStore.h"

@implementation HMBookmarkDataStore

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self defaultManager];
	});
}
- (NSString *)modelName
{
	return @"Bookmark";
}
- (NSString *)storeFileName
{
	return @"Bookmark.storedata";
}
- (NSString *)storeType
{
	return NSSQLiteStoreType;
}
- (NSDictionary *)storeOptions
{
	NSDictionary *options = @{
							  NSSQLitePragmasOption : @{@"journal_mode" : @"MEMORY"},
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
