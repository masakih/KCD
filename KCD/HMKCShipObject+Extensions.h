//
//  HMKCShipObject+Extensions.h
//  KCD
//
//  Created by Hori,Masaki on 2014/06/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCShipObject.h"

@interface HMKCShipObject (Extensions)

@property (readonly) NSString *name;
@property (readonly) NSString *shortTypeName;

@property (readonly) NSNumber *next;

@property (readonly) NSInteger status;
@property (readonly) NSColor *statusColor;
@property (readonly) NSColor *conditionColor;

@property (readonly) NSNumber *maxBull;
@property (readonly) NSNumber *maxFuel;

@property (readonly) IBOutlet NSColor *planColor;


@property (readonly) NSNumber *upgradeLevel;
@property (readonly) NSNumber *upgradeExp;

@property (readonly) NSNumber *totalEquipment;

@property (readonly) NSNumber *seiku;
@property (readonly) NSNumber *extraSeiku;

@property (readonly) NSNumber *totalDrums;

@property (readonly) NSNumber *guardEscaped; // NSNumber of BOLL
@end
