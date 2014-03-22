//
//  HMKenzoHistory.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMKenzoHistory : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *fuel;
@property (nonatomic, retain) NSNumber *bull;
@property (nonatomic, retain) NSNumber *steel;
@property (nonatomic, retain) NSNumber *bauxite;
@property (nonatomic, retain) NSNumber *kaihatusizai;
@property (nonatomic, retain) NSNumber *isLarge;
@property (nonatomic, retain) NSDate *date;

@end
