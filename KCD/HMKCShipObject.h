//
//  HMKCShipObject.h
//  KCD
//
//  Created by Hori,Masaki on 2014/12/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCManagedObject.h"

@class HMKCMasterShipObject, HMKCSlotItemObject;

@interface HMKCShipObject : HMKCManagedObject

@property (nonatomic, retain) NSNumber * bull;
@property (nonatomic, retain) NSNumber * cond;
@property (nonatomic, retain) NSNumber * exp;
@property (nonatomic, retain) NSNumber * fleet;
@property (nonatomic, retain) NSNumber * fuel;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * kaihi_0;
@property (nonatomic, retain) NSNumber * kaihi_1;
@property (nonatomic, retain) NSNumber * karyoku_0;
@property (nonatomic, retain) NSNumber * karyoku_1;
@property (nonatomic, retain) NSNumber * kyouka_0;
@property (nonatomic, retain) NSNumber * kyouka_1;
@property (nonatomic, retain) NSNumber * kyouka_2;
@property (nonatomic, retain) NSNumber * kyouka_3;
@property (nonatomic, retain) NSNumber * kyouka_4;
@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSNumber * locked_equip;
@property (nonatomic, retain) NSNumber * lucky_0;
@property (nonatomic, retain) NSNumber * lucky_1;
@property (nonatomic, retain) NSNumber * lv;
@property (nonatomic, retain) NSNumber * maxhp;
@property (nonatomic, retain) NSNumber * ndock_time;
@property (nonatomic, retain) NSNumber * nowhp;
@property (nonatomic, retain) NSNumber * onslot_0;
@property (nonatomic, retain) NSNumber * onslot_1;
@property (nonatomic, retain) NSNumber * onslot_2;
@property (nonatomic, retain) NSNumber * onslot_3;
@property (nonatomic, retain) NSNumber * onslot_4;
@property (nonatomic, retain) NSNumber * raisou_0;
@property (nonatomic, retain) NSNumber * raisou_1;
@property (nonatomic, retain) NSNumber * sakuteki_0;
@property (nonatomic, retain) NSNumber * sakuteki_1;
@property (nonatomic, retain) NSNumber * sally_area;
@property (nonatomic, retain) NSNumber * ship_id;
@property (nonatomic, retain) NSNumber * slot_0;
@property (nonatomic, retain) NSNumber * slot_1;
@property (nonatomic, retain) NSNumber * slot_2;
@property (nonatomic, retain) NSNumber * slot_3;
@property (nonatomic, retain) NSNumber * slot_4;
@property (nonatomic, retain) NSNumber * slot_ex;
@property (nonatomic, retain) NSNumber * sortno;
@property (nonatomic, retain) NSNumber * soukou_0;
@property (nonatomic, retain) NSNumber * soukou_1;
@property (nonatomic, retain) NSNumber * srate;
@property (nonatomic, retain) NSNumber * taiku_0;
@property (nonatomic, retain) NSNumber * taiku_1;
@property (nonatomic, retain) NSNumber * taisen_0;
@property (nonatomic, retain) NSNumber * taisen_1;
@property (nonatomic, retain) NSOrderedSet *equippedItem;
@property (nonatomic, retain) HMKCMasterShipObject *master_ship;
@end

@interface HMKCShipObject (CoreDataGeneratedAccessors)

- (void)insertObject:(HMKCSlotItemObject *)value inEquippedItemAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEquippedItemAtIndex:(NSUInteger)idx;
- (void)insertEquippedItem:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEquippedItemAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEquippedItemAtIndex:(NSUInteger)idx withObject:(HMKCSlotItemObject *)value;
- (void)replaceEquippedItemAtIndexes:(NSIndexSet *)indexes withEquippedItem:(NSArray *)values;
- (void)addEquippedItemObject:(HMKCSlotItemObject *)value;
- (void)removeEquippedItemObject:(HMKCSlotItemObject *)value;
- (void)addEquippedItem:(NSOrderedSet *)values;
- (void)removeEquippedItem:(NSOrderedSet *)values;
@end
