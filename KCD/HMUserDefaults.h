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

@property (nonatomic, weak) NSColor *plan04Color;
@property (nonatomic, weak) NSColor *plan05Color;
@property (nonatomic, weak) NSColor *plan06Color;

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

/**
 * 非表示設定の艦娘を改造可能艦リストに表示するか
 */
@property BOOL showsExcludedShipInUpgradableList;

/**
 * 装備リストに表示する装備
 * -1 : すべて
 * 0 : 装備されていない
 * 1 : 装備されている
 */
@property (nonatomic, weak) NSNumber *showEquipmentType;


/**
 * 艦隊リストの表示位置
 * 0 : 上
 * 1 : 下
 * 2 : 上下に分割
 */
@property NSInteger fleetViewPosition;

/**
 * 艦隊リスト内の艦娘の並び順序
 * 0 : 左向き複縦陣
 * 1 : 左から右
 */
@property NSInteger fleetViewShipOrder;

/**
 * 明石さんタイマー
 */
@property NSDate *repairTime;

/**
 * 前回終了時に連合艦隊表示だったかどうか
 */
@property BOOL lastHasCombinedView;

/**
 * 自動連合艦隊表示モード
 */
@property BOOL autoCombinedView;

/**
 * スワイプで連合艦隊ビューの切り替えをするか
 */
@property BOOL useSwipeChangeCombinedView;


/**
 * 連結するスクリーンショットの列数
 */
@property NSInteger screenshotEditorColumnCount;

/**
 * スクリーンショットの切り抜きタイプ
 */
@property NSInteger scrennshotEditorType;

/**
 * 古い履歴を削除する
 */
@property BOOL cleanOldHistoryItems;

/**
 * 削除を開始する経過日数
 */
@property NSInteger cleanSiceDays;

/**
 * 時報の通知を出すか
 */
@property BOOL notifyTimeSignal;

/**
 * 時報の通知を何分前に出すか
 */
@property NSNumber *notifyTimeBeforeTimeSignal;

/**
 * 時報の通知時に音を鳴らすか
 */
@property BOOL playNotifyTimeSignalSound;
@end
