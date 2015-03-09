//
//  HMFleetInformation.h
//  KCD
//
//  Created by Hori,Masaki on 2014/09/28.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#ifdef DEBUG

#import <Foundation/Foundation.h>

@class HMKCShipObject;
@class HMKCDeck;

@interface HMFleetInformation : NSObject

@property (nonatomic, strong) NSNumber *selectedFleetNumber;


// prpperties of Selected Fleet
@property (readonly) NSString *name;

@property (readonly) HMKCShipObject *flagShip;
@property (readonly) HMKCShipObject *secondShip;
@property (readonly) HMKCShipObject *thirdShip;
@property (readonly) HMKCShipObject *fourthShip;
@property (readonly) HMKCShipObject *fifthShip;
@property (readonly) HMKCShipObject *sixthShip;

@property (readonly) NSNumber *totalSakuteki;
@property (readonly) NSNumber *totalSeiku;


//
- (HMKCDeck *)fleetAtIndex:(NSInteger)fleetNumner;
- (NSArray *)fleetMemberAtIndex:(NSInteger)fleetNumber;


@end

#endif
