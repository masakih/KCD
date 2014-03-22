//
//  HMKaihatuHistory.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMKaihatuHistory : NSManagedObject

@property (nonatomic, retain) NSNumber *bull;
@property (nonatomic, retain) NSNumber *bauxite;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSNumber *fuel;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *steel;
@property (nonatomic, retain) NSNumber *kaihatusizai;

@end
