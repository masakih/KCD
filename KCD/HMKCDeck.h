//
//  HMKCDeck.h
//  KCD
//
//  Created by Hori,Masaki on 2014/10/05.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "HMKCManagedObject.h"


@interface HMKCDeck : HMKCManagedObject

@property (nonatomic, retain) NSNumber * flagship;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * member_id;
@property (nonatomic, retain) NSNumber * mission_0;
@property (nonatomic, retain) NSNumber * mission_1;
@property (nonatomic, retain) NSNumber * mission_2;
@property (nonatomic, retain) NSNumber * mission_3;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * name_id;
@property (nonatomic, retain) NSNumber * ship_0;
@property (nonatomic, retain) NSNumber * ship_1;
@property (nonatomic, retain) NSNumber * ship_2;
@property (nonatomic, retain) NSNumber * ship_3;
@property (nonatomic, retain) NSNumber * ship_4;
@property (nonatomic, retain) NSNumber * ship_5;

@end
