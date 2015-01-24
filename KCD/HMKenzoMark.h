//
//  HMKenzoMark.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMKenzoMark : NSManagedObject

@property (nonatomic, retain) NSNumber * bauxite;
@property (nonatomic, retain) NSNumber * bull;
@property (nonatomic, retain) NSNumber * commanderLv;
@property (nonatomic, retain) NSNumber * created_ship_id;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * flagShipLv;
@property (nonatomic, retain) NSString * flagShipName;
@property (nonatomic, retain) NSNumber * fuel;
@property (nonatomic, retain) NSNumber * kaihatusizai;
@property (nonatomic, retain) NSNumber * kDockId;
@property (nonatomic, retain) NSNumber * steel;

@end
