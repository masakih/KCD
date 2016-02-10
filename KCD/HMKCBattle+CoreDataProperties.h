//
//  HMKCBattle+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/09.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HMKCBattle.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKCBattle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *battleCell;
@property (nullable, nonatomic, retain) NSNumber *deckId;
@property (nullable, nonatomic, retain) NSNumber *isBossCell;
@property (nullable, nonatomic, retain) NSNumber *mapArea;
@property (nullable, nonatomic, retain) NSNumber *mapInfo;
@property (nullable, nonatomic, retain) NSNumber *no;
@property (nullable, nonatomic, retain) NSOrderedSet<HMKCDamage *> *damages;

@end

@interface HMKCBattle (CoreDataGeneratedAccessors)

- (void)insertObject:(HMKCDamage *)value inDamagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDamagesAtIndex:(NSUInteger)idx;
- (void)insertDamages:(NSArray<HMKCDamage *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDamagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDamagesAtIndex:(NSUInteger)idx withObject:(HMKCDamage *)value;
- (void)replaceDamagesAtIndexes:(NSIndexSet *)indexes withDamages:(NSArray<HMKCDamage *> *)values;
- (void)addDamagesObject:(HMKCDamage *)value;
- (void)removeDamagesObject:(HMKCDamage *)value;
- (void)addDamages:(NSOrderedSet<HMKCDamage *> *)values;
- (void)removeDamages:(NSOrderedSet<HMKCDamage *> *)values;

@end

NS_ASSUME_NONNULL_END
