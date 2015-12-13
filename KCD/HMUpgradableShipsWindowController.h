//
//  HMUpgradableShipsWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/10/26.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMUpgradableShipsWindowController : NSWindowController

@property BOOL showLevelOneShipInUpgradableList;
@property BOOL showsExcludedShipInUpgradableList;
@property (readonly) NSPredicate *filterPredicate;

@end

BOOL isExcludeShipID(id shipID);
