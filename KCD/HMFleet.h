//
//  HMFleet.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/11.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMKCShipObject;

@interface HMFleet : NSObject

@property (readonly) NSString *name;

@property (readonly) NSArray<HMKCShipObject *> *ships;

@property (readonly) HMKCShipObject *flagShip;
@property (readonly) HMKCShipObject *secondShip;
@property (readonly) HMKCShipObject *thirdShip;
@property (readonly) HMKCShipObject *fourthShip;
@property (readonly) HMKCShipObject *fifthShip;
@property (readonly) HMKCShipObject *sixthShip;


@property (readonly) NSNumber *totalSakuteki;
@property (readonly) NSNumber *totalSeiku;
@property (readonly) NSNumber *totalCalclatedSeiku;
@property (readonly) NSNumber *totalLevel;
@property (readonly) NSNumber *totalDrums;


+ (instancetype)fleetWithNumber:(NSNumber *)fleetNumber;


- (HMKCShipObject *)objectAtIndexedSubscript:(NSUInteger)idx;

@end
