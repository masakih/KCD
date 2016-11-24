//
//  HMKCAirBasePlaneInfo+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/11/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMKCAirBasePlaneInfo.h"


NS_ASSUME_NONNULL_BEGIN

@interface HMKCAirBasePlaneInfo (CoreDataProperties)

+ (NSFetchRequest<HMKCAirBasePlaneInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *squadron_id;
@property (nullable, nonatomic, copy) NSNumber *state;
@property (nullable, nonatomic, copy) NSNumber *slotid;
@property (nullable, nonatomic, copy) NSNumber *cond;
@property (nullable, nonatomic, copy) NSNumber *count;
@property (nullable, nonatomic, copy) NSNumber *max_count;
@property (nullable, nonatomic, retain) HMKCAirBase *airBase;

@end

NS_ASSUME_NONNULL_END
