//
//  HMFleetViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMKCDeck;

typedef NS_ENUM(NSUInteger, HMFleetViewType) {
	detailViewType,
	minimumViewType,
};

typedef NS_ENUM(NSInteger, HMFleetViewShipOrder) {
	doubleLine = 0,
	leftToRight = 1,
};


@interface HMFleetViewController : NSViewController

- (instancetype)initWithViewType:(HMFleetViewType)type;

@property (readonly) HMFleetViewType type;

@property (strong) HMKCDeck* fleet;
@property NSInteger fleetNumber;
@property HMFleetViewShipOrder shipOrder;
@property BOOL enableAnimation;

@property (readonly) BOOL canDivide;
@property (readonly) CGFloat normalHeight;
@property (readonly) CGFloat upsideHeight;

@property (readonly) NSNumber *totalSakuteki;
@property (readonly) NSNumber *totalSeiku;
@end
