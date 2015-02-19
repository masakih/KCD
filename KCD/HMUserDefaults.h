//
//  HMUserDefaults.h
//  KCD
//
//  Created by Hori,Masaki on 2014/06/01.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMUserDefaults;

extern HMUserDefaults *HMStandardDefaults;


@interface HMUserDefaults : NSObject

+ (instancetype)hmStandardDefauls;

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


/**
 *  取得可能艦娘数
 */
@property NSInteger minimumColoredShipCount;

/**
 *  2014年夏イベント時の出撃海域による色分けの有効／無効
 */
@property BOOL showsPlanColor;
/**
 *  作戦０１の色
 */
@property (nonatomic, weak) NSColor *plan01Color;
/**
 *  作戦０２の色
 */
@property (nonatomic, weak) NSColor *plan02Color;
/**
 * 作戦０３の色
 */
@property (nonatomic, weak) NSColor *plan03Color;


/**
 *  スクリーンショットの縁取りの幅
 */
@property CGFloat screenShotBorderWidth;

/**
 *  スクリーンショットに提督名マスクを施すか
 */
@property BOOL useMask;

/**
 *  スクリーンショットを保存する場所
 */
@property (nonatomic, weak) NSString *screenShotSaveDirectory;

/**
 * スクリーンショットを撮ったときリストウインドウを最前面にするか
 */
@property BOOL showsListWindowAtScreenshot;

/**
 * スクリーンショットのプレビューのズーム値
 */
@property NSNumber *screenshotPreviewZoomValue;

/**
 *  遠征帰還時の通知音を鳴らす
 */
@property BOOL playFinishMissionSound;

/**
 *  入渠完了時の通知音を鳴らす
 */
@property BOOL playFinishNyukyoSound;

/**
 *  建造完了時の通知音を鳴らす
 */
@property BOOL playFinishKenzoSound;

/**
 * Lv.1の艦娘を改造可能艦リストに表示するか
 */
@property BOOL showLevelOneShipInUpgradableList;

@end
