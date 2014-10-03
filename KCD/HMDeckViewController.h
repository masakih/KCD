//
//  HMDeckViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/04/12.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMFleetInformation;

@interface HMDeckViewController : NSViewController

@property (readonly) HMFleetInformation *fleetInfo;
@property NSInteger selectedDeck;
@end
