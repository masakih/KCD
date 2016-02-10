//
//  HMKCGuardEscaped+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/09.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HMKCGuardEscaped.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKCGuardEscaped (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *ensured;
@property (nullable, nonatomic, retain) NSNumber *shipID;

@end

NS_ASSUME_NONNULL_END
