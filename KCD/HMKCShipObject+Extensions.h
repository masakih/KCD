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


@property (readonly) NSColor *statusColor;
@property (readonly) NSColor *conditionColor;

@property (readonly) NSNumber *maxBull;
@property (readonly) NSNumber *maxFuel;

@property (readonly) IBOutlet NSColor *planColor;


@end
