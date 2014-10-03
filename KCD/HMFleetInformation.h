//
//  HMFleetInformation.h
//  KCD
//
//  Created by Hori,Masaki on 2014/09/28.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMKCShipObject;

@interface HMFleetInformation : NSObject

@property (nonatomic, strong) NSNumber *fleetNumber;

@property (readonly) NSString *name;

@property (readonly) HMKCShipObject *flagShip;
@property (readonly) HMKCShipObject *secondShip;
@property (readonly) HMKCShipObject *thirdShip;
@property (readonly) HMKCShipObject *fourthShip;
@property (readonly) HMKCShipObject *fifthShip;
@property (readonly) HMKCShipObject *sixthShip;

@property (readonly) NSNumber *totalSakuteki;

@end
