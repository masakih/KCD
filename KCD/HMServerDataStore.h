//
//  HMServerDataStore.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCoreDataManager.h"

@class HMKCShipObject;

/**
 サーバーサイドから取り込むデータを保存する
 */
@interface HMServerDataStore : HMCoreDataManager

@end

@interface HMServerDataStore (HMAccessor)
- (nullable NSArray<HMKCShipObject *> *)shipsByDeckID:(nonnull NSNumber *)deckId;
- (nullable HMKCShipObject *)shipByID:(nonnull NSNumber *)shipId;
- (nullable NSNumber *) masterSlotItemIDbySlotItem:(nonnull NSNumber *)value;
@end
