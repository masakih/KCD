//
//  HMTemporaryDataStore.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMTemporaryDataStore.h"

#import "HMKCDamage.h"
#import "HMKCBattle.h"

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


@implementation HMTemporaryDataStore (HMAccessor)

- (nullable NSArray<HMKCBattle *> *)battles
{
    NSError *error = nil;
    NSArray<HMKCBattle *> *array = [self objectsWithEntityName:@"Battle"
                                                     predicate:nil
                                                         error:&error];
    if(error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return array;
}
- (nullable NSArray<HMKCDamage *> *)damagesWithSortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
{
    NSError *error = nil;
    NSArray<HMKCDamage *> *array = [self objectsWithEntityName:@"Damage"
                                               sortDescriptors:sortDescriptors
                                                     predicate:nil
                                                         error:&error];
    if(error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    return array;
}

@end

