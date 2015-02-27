//
//  HMKCSlotItemObject+Extensions.h
//  KCD
//
//  Created by Hori,Masaki on 2014/10/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCSlotItemObject.h"

@interface HMKCSlotItemObject (Extensions)

@property (readonly) NSString *name;

@property (readonly) NSString *equippedShipName;
@property (readonly) NSNumber *equippedShipLv;
@property (readonly) NSNumber *masterSlotItemRare;
@property (readonly) NSString *typeName;

@property (readonly) NSNumber *isLocked;
@end
