//
//  HMKenzoHistory.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMKenzoHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * bauxite;
@property (nonatomic, retain) NSNumber * bull;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * fuel;
@property (nonatomic, retain) NSNumber * kaihatusizai;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * steel;
@property (nonatomic, retain) NSNumber * sTypeId;
@property (nonatomic, retain) NSString * flagShipName;
@property (nonatomic, retain) NSNumber * flagShipLv;
@property (nonatomic, retain) NSNumber * commanderLv;

@property (readonly) NSNumber *isLarge;

@end
