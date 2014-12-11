//
//  HMKCMasterSlotItemObject.h
//  KCD
//
//  Created by Hori,Masaki on 2014/12/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCManagedObject.h"

@class HMKCSlotItemObject;

@interface HMKCMasterSlotItemObject : HMKCManagedObject

@property (nonatomic, retain) NSNumber * atap;
@property (nonatomic, retain) NSNumber * bakk;
@property (nonatomic, retain) NSNumber * baku;
@property (nonatomic, retain) NSNumber * broken_0;
@property (nonatomic, retain) NSNumber * broken_1;
@property (nonatomic, retain) NSNumber * broken_2;
@property (nonatomic, retain) NSNumber * broken_3;
@property (nonatomic, retain) NSNumber * houg;
@property (nonatomic, retain) NSNumber * houk;
@property (nonatomic, retain) NSNumber * houm;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * leng;
@property (nonatomic, retain) NSNumber * luck;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * raig;
@property (nonatomic, retain) NSNumber * raik;
@property (nonatomic, retain) NSNumber * raim;
@property (nonatomic, retain) NSNumber * rare;
@property (nonatomic, retain) NSNumber * sakb;
@property (nonatomic, retain) NSNumber * saku;
@property (nonatomic, retain) NSNumber * soku;
@property (nonatomic, retain) NSNumber * sortno;
@property (nonatomic, retain) NSNumber * souk;
@property (nonatomic, retain) NSNumber * taik;
@property (nonatomic, retain) NSNumber * tais;
@property (nonatomic, retain) NSNumber * tyku;
@property (nonatomic, retain) NSNumber * type_0;
@property (nonatomic, retain) NSNumber * type_1;
@property (nonatomic, retain) NSNumber * type_2;
@property (nonatomic, retain) NSNumber * type_3;
@property (nonatomic, retain) NSNumber * usebull;
@property (nonatomic, retain) NSSet *slotItems;
@end

@interface HMKCMasterSlotItemObject (CoreDataGeneratedAccessors)

- (void)addSlotItemsObject:(HMKCSlotItemObject *)value;
- (void)removeSlotItemsObject:(HMKCSlotItemObject *)value;
- (void)addSlotItems:(NSSet *)values;
- (void)removeSlotItems:(NSSet *)values;

@end
