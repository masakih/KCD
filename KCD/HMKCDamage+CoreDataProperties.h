//
//  HMKCDamage+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/09.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HMKCDamage.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKCDamage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *damage;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) HMKCBattle *battle;

@end

NS_ASSUME_NONNULL_END
