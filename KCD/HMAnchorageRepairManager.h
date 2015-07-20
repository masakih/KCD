//
//  HMAnchorageRepairManager.h
//  KCD
//
//  Created by Hori,Masaki on 2015/07/19.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMKCDeck;

@interface HMAnchorageRepairManager : NSObject

- (instancetype)initWithDeck:(HMKCDeck *)deck;
@property (readonly) NSDate *repairTime;

@property (readonly) NSNumber *repairableShipCount;

@end
