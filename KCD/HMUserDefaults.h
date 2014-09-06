//
//  HMUserDefaults.h
//  KCD
//
//  Created by Hori,Masaki on 2014/06/01.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMUserDefaults;

extern HMUserDefaults *HMStandardDefaults;


@interface HMUserDefaults : NSObject

@property (nonatomic, weak) NSArray *slotItemSortDescriptors;
@property (nonatomic, weak) NSArray *powerupSupportSortDecriptors;
@property (nonatomic, weak) NSArray *shipviewSortDescriptors;

@property BOOL showsDebugMenu;

@property BOOL hideMaxKaryoku;
@property BOOL hideMaxRaisou;
@property BOOL hideMaxTaiku;
@property BOOL hideMaxSoukou;
@property BOOL hideMaxLucky;

@property BOOL appendKanColleTag;

@property (nonatomic, weak) NSDate *prevReloadDate;

@property NSInteger minimumColoredShipCount;

/**
 *  2014年夏イベント時の出撃海域による色分けの有効／無効
 */
@property BOOL showsPlanColor;


/**
 *  スクリーンショットの縁取りの幅
 */
@property CGFloat screenShotBorderWidth;

/**
 *  スクリーンショットに提督名マスクを施すか
 */
@property BOOL useMask;
@end
