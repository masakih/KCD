//
//  HMKCMasterMapArea+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/10.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HMKCMasterMapArea.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKCMasterMapArea (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *type;

@end

NS_ASSUME_NONNULL_END
