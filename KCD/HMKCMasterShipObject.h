//
//  HMKCMasterShipObject.h
//  KCD
//
//  Created by Hori,Masaki on 2014/12/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCManagedObject.h"

@class HMKCShipObject;

@interface HMKCMasterShipObject : HMKCManagedObject

@property (nonatomic, retain) NSNumber * afterbull;
@property (nonatomic, retain) NSNumber * afterfuel;
@property (nonatomic, retain) NSNumber * afterlv;
@property (nonatomic, retain) NSNumber * aftershipid;
@property (nonatomic, retain) NSNumber * backs;
@property (nonatomic, retain) NSNumber * broken_0;
@property (nonatomic, retain) NSNumber * broken_1;
@property (nonatomic, retain) NSNumber * broken_2;
@property (nonatomic, retain) NSNumber * broken_3;
@property (nonatomic, retain) NSNumber * buildtime;
@property (nonatomic, retain) NSNumber * bull_max;
@property (nonatomic, retain) NSNumber * fuel_max;
@property (nonatomic, retain) NSString * getmes;
@property (nonatomic, retain) NSNumber * houg_0;
@property (nonatomic, retain) NSNumber * houg_1;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * leng;
@property (nonatomic, retain) NSNumber * luck_0;
@property (nonatomic, retain) NSNumber * luck_1;
@property (nonatomic, retain) NSNumber * maxeq_0;
@property (nonatomic, retain) NSNumber * maxeq_1;
@property (nonatomic, retain) NSNumber * maxeq_2;
@property (nonatomic, retain) NSNumber * maxeq_3;
@property (nonatomic, retain) NSNumber * maxeq_4;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * powup_0;
@property (nonatomic, retain) NSNumber * powup_1;
@property (nonatomic, retain) NSNumber * powup_2;
@property (nonatomic, retain) NSNumber * powup_3;
@property (nonatomic, retain) NSNumber * raig_0;
@property (nonatomic, retain) NSNumber * raig_1;
@property (nonatomic, retain) NSString * sinfo;
@property (nonatomic, retain) NSNumber * slot_num;
@property (nonatomic, retain) NSNumber * soku;
@property (nonatomic, retain) NSNumber * sortno;
@property (nonatomic, retain) NSNumber * souk_0;
@property (nonatomic, retain) NSNumber * souk_1;
@property (nonatomic, retain) NSNumber * taik_0;
@property (nonatomic, retain) NSNumber * taik_1;
@property (nonatomic, retain) NSNumber * tais_0;
@property (nonatomic, retain) NSNumber * tyku_0;
@property (nonatomic, retain) NSNumber * tyku_1;
@property (nonatomic, retain) NSNumber * voicef;
@property (nonatomic, retain) NSString * yomi;
@property (nonatomic, retain) NSSet *ships;
@property (nonatomic, retain) HMKCManagedObject *stype;
@end

@interface HMKCMasterShipObject (CoreDataGeneratedAccessors)

- (void)addShipsObject:(HMKCShipObject *)value;
- (void)removeShipsObject:(HMKCShipObject *)value;
- (void)addShips:(NSSet *)values;
- (void)removeShips:(NSSet *)values;

@end
