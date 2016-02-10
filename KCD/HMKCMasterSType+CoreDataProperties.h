//
//  HMKCMasterSType+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/10.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HMKCMasterSType.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKCMasterSType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *kcnt;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *scnt;
@property (nullable, nonatomic, retain) NSNumber *sortno;
@property (nullable, nonatomic, retain) NSSet<HMKCMasterShipObject *> *ships;

@end

@interface HMKCMasterSType (CoreDataGeneratedAccessors)

- (void)addShipsObject:(HMKCMasterShipObject *)value;
- (void)removeShipsObject:(HMKCMasterShipObject *)value;
- (void)addShips:(NSSet<HMKCMasterShipObject *> *)values;
- (void)removeShips:(NSSet<HMKCMasterShipObject *> *)values;

@end

NS_ASSUME_NONNULL_END
