//
//  HMMainTabVIewItemViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2016/12/07.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, HMShipType) {
    kHMAllType,
    kHMDestroyer,
    kHMLightCruiser,
    kHMHeavyCruiser,
    kHMAircraftCarrier,
    kHMBattleShip,
    kHMSubmarine,
    kHMOtherType,
};

@interface HMMainTabVIewItemViewController : NSViewController

@property (readonly) BOOL hasShipTypeSelector;
@property (nonatomic) HMShipType selectedShipType;

- (NSPredicate *)predicateForShipType:(HMShipType)shipType;

@end
