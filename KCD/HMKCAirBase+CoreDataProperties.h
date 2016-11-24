//
//  HMKCAirBase+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/11/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMKCAirBase.h"


NS_ASSUME_NONNULL_BEGIN

@interface HMKCAirBase (CoreDataProperties)

+ (NSFetchRequest<HMKCAirBase *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *rid;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *area_id;
@property (nullable, nonatomic, copy) NSNumber *distance;
@property (nullable, nonatomic, copy) NSNumber *action_kind;
@property (nullable, nonatomic, retain) NSOrderedSet<HMKCAirBasePlaneInfo *> *planeInfo;

@end

@interface HMKCAirBase (CoreDataGeneratedAccessors)

- (void)insertObject:(HMKCAirBasePlaneInfo *)value inPlaneInfoAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlaneInfoAtIndex:(NSUInteger)idx;
- (void)insertPlaneInfo:(NSArray<HMKCAirBasePlaneInfo *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlaneInfoAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlaneInfoAtIndex:(NSUInteger)idx withObject:(HMKCAirBasePlaneInfo *)value;
- (void)replacePlaneInfoAtIndexes:(NSIndexSet *)indexes withPlaneInfo:(NSArray<HMKCAirBasePlaneInfo *> *)values;
- (void)addPlaneInfoObject:(HMKCAirBasePlaneInfo *)value;
- (void)removePlaneInfoObject:(HMKCAirBasePlaneInfo *)value;
- (void)addPlaneInfo:(NSOrderedSet<HMKCAirBasePlaneInfo *> *)values;
- (void)removePlaneInfo:(NSOrderedSet<HMKCAirBasePlaneInfo *> *)values;

@end

NS_ASSUME_NONNULL_END
