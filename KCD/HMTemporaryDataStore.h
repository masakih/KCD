//
//  HMTemporaryDataStore.h
//  KCD
//
//  Created by Hori,Masaki on 2014/05/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCoreDataManager.h"

@class HMKCBattle, HMKCDamage;

@interface HMTemporaryDataStore : HMCoreDataManager

@end

@interface HMTemporaryDataStore (HMAccessor)
- (nullable NSArray<HMKCBattle *> *)battles;
- (nullable NSArray<HMKCDamage *> *)damagesWithSortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors;
@end
