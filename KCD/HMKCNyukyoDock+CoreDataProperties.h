//
//  HMKCNyukyoDock+CoreDataProperties.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/10.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HMKCNyukyoDock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKCNyukyoDock (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *complete_time;
@property (nullable, nonatomic, retain) NSString *complete_time_str;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *item1;
@property (nullable, nonatomic, retain) NSNumber *item2;
@property (nullable, nonatomic, retain) NSNumber *item3;
@property (nullable, nonatomic, retain) NSNumber *item4;
@property (nullable, nonatomic, retain) NSNumber *member_id;
@property (nullable, nonatomic, retain) NSNumber *ship_id;
@property (nullable, nonatomic, retain) NSNumber *state;

@end

NS_ASSUME_NONNULL_END
