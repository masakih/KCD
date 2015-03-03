//
//  HMFleetViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMKCDeck;

@interface HMFleetViewController : NSViewController

@property (strong) HMKCDeck* fleet;
@property NSInteger fleetNumber;

@property (readonly) NSNumber *totalSakuteki;
@property (readonly) NSNumber *totalSeiku;
@end
