//
//  HMKCDeck+Extension.h
//  KCD
//
//  Created by Hori,Masaki on 2014/10/05.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCDeck.h"
#import "HMKCShipObject.h"

@interface HMKCDeck (Extension)

@property (readonly) HMKCShipObject *flagShip;
@property (readonly) HMKCShipObject *secondShip;
@property (readonly) HMKCShipObject *thirdShip;
@property (readonly) HMKCShipObject *fourthShip;
@property (readonly) HMKCShipObject *fifthShip;
@property (readonly) HMKCShipObject *sixthShip;

- (HMKCShipObject *)objectAtIndexedSubscript:(NSUInteger)idx;

@end
