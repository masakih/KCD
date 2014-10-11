//
//  HMKCSlotItemObject.h
//  KCD
//
//  Created by Hori,Masaki on 2014/10/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCManagedObject.h"

@class HMKCManagedObject, HMKCShipObject;

@interface HMKCSlotItemObject : HMKCManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSNumber * slotitem_id;
@property (nonatomic, retain) HMKCShipObject *equippedShip;
@property (nonatomic, retain) HMKCManagedObject *master_slotItem;

@end
