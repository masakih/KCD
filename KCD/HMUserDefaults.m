//
//  HMUserDefaults.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/01.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMUserDefaults.h"

HMUserDefaults *HMStandardDefaults = nil;


@implementation HMUserDefaults

@dynamic slotItemSortDescriptors, shipviewSortDescriptors, powerupSupportSortDecriptors;
@dynamic showsDebugMenu;
@dynamic hideMaxKaryoku, hideMaxRaisou, hideMaxLucky, hideMaxSoukou, hideMaxTaiku;
@dynamic appendKanColleTag;
@dynamic prevReloadDate;
@dynamic repairTime;

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		HMStandardDefaults = [self new];
		
		NSColor *plan01Color = [NSColor colorWithCalibratedRed:0.000 green:0.043 blue:0.518 alpha:1.000];
		NSColor *plan02Color = [NSColor colorWithCalibratedRed:0.800 green:0.223 blue:0.000 alpha:1.000];
		NSColor *plan03Color = [NSColor colorWithCalibratedRed:0.539 green:0.012 blue:0.046 alpha:1.000];
		NSColor *plan04Color = [NSColor colorWithCalibratedRed:0.000 green:0.535 blue:0.535 alpha:1.000];
		NSColor *plan05Color = [NSColor colorWithCalibratedRed:0.376 green:0.035 blue:0.535 alpha:1.000];
		NSColor *plan06Color = [NSColor colorWithCalibratedRed:0.535 green:0.535 blue:0.000 alpha:1.000];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:
		 @{
		   @"screenShotBorderWidth" : @(0.0),
		   @"plan01Color" : [NSKeyedArchiver archivedDataWithRootObject:plan01Color],
		   @"plan02Color" : [NSKeyedArchiver archivedDataWithRootObject:plan02Color],
		   @"plan03Color" : [NSKeyedArchiver archivedDataWithRootObject:plan03Color],
		   @"plan04Color" : [NSKeyedArchiver archivedDataWithRootObject:plan04Color],
		   @"plan05Color" : [NSKeyedArchiver archivedDataWithRootObject:plan05Color],
		   @"plan06Color" : [NSKeyedArchiver archivedDataWithRootObject:plan06Color],
		   @"screenshotPreviewZoomValue" : @(0.4),
		   @"showEquipmentType" : @(-1),
		   @"fleetViewPosition" : @(1),
		   @"autoCombinedView" : @YES,
		   @"screenshotEditorColumnCount" : @2,
		   
		   @"cleanSiceDays" : @90,
           
           @"notifyTimeSignal" : @NO,
           @"notifyTimeBeforeTimeSignal" : @5,
		   
		   }
		 ];
	});
}

+ (instancetype)hmStandardDefauls
{
	return HMStandardDefaults;
}

- (void)setObject:(id)value forKey:(NSString *)key
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}
- (id)objectForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
- (NSString *)stringForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}
- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
}
- (NSInteger)integerForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}
- (void)setDouble:(double)value forKey:(NSString *)key
{
	[[NSUserDefaults standardUserDefaults] setDouble:value forKey:key];
}
- (double)doubleForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] doubleForKey:key];
}
- (void)setBool:(BOOL)value forKey:(NSString *)key
{
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
}
- (BOOL)boolForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
- (void)setKeyedArchiveObject:(id)value forKey:(NSString *)key
{
	NSData *data = nil;
	if(value) {
		data = [NSKeyedArchiver archivedDataWithRootObject:value];
	}
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}
- (id)keyedUnarchiveObject:(NSString *)key
{
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

#pragma mark-Properties
- (void)setSlotItemSortDescriptors:(NSArray *)slotItemSortDescriptors
{
	[self setKeyedArchiveObject:slotItemSortDescriptors forKey:@"slotItemSortKey2"];
}
- (NSArray *)slotItemSortDescriptors
{
	NSArray *array = [self keyedUnarchiveObject:@"slotItemSortKey2"];
	if(array) {
		NSMutableArray *result = [NSMutableArray new];
		for(NSSortDescriptor *item in array) {
			if(![item.key hasPrefix:@"master_ship"] && ![item.key hasPrefix:@"master_slotItem"]) {
				[result addObject:item];
			}
		}
		
		return [NSArray arrayWithArray:result];
	}
	return [NSArray new];
}
- (void)setShipviewSortDescriptors:(NSArray *)shipviewSortDescriptors
{
	[self setKeyedArchiveObject:shipviewSortDescriptors forKey:@"shipviewsortdescriptor"];
}
- (NSArray *)shipviewSortDescriptors
{
	NSArray *array = [self keyedUnarchiveObject:@"shipviewsortdescriptor"];
	if(array) {
		NSMutableArray *result = [NSMutableArray new];
		for(NSSortDescriptor *item in array) {
			if(![item.key hasPrefix:@"master_ship"]) {
				[result addObject:item];
			}
		}
		
		return [NSArray arrayWithArray:result];
	}
	return [NSArray new];
}
- (void)setPowerupSupportSortDecriptors:(NSArray *)powerupSupportSortDecriptors
{
	[self setKeyedArchiveObject:powerupSupportSortDecriptors forKey:@"powerupsupportsortdecriptor"];
}
- (NSArray *)powerupSupportSortDecriptors
{
	NSArray *array = [self keyedUnarchiveObject:@"powerupsupportsortdecriptor"];
	if(array) {
		NSMutableArray *result = [NSMutableArray new];
		for(NSSortDescriptor *item in array) {
			if(![item.key hasPrefix:@"master_ship"]) {
				[result addObject:item];
			}
		}
		
		return [NSArray arrayWithArray:result];
	}
	return [NSArray new];
}


- (NSDateFormatter *)dateFormatter
{
	NSDateFormatter *formatter = [NSDateFormatter new];
	formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z";
	
	return formatter;
}
- (void)setPrevReloadDate:(NSDate *)prevReloadDate
{
	if(prevReloadDate) {
		NSString *dateString = [self.dateFormatter stringFromDate:prevReloadDate];
		[self setObject:dateString forKey:@"previousReloadDateString"];
	}
}
- (NSDate *)prevReloadDate
{
	NSDate *date = nil;
	NSString *dateString = [self stringForKey:@"previousReloadDateString"];
	if(dateString) {
		date = [self.dateFormatter dateFromString:dateString];
	}
	return date;
}

- (void)setShowsDebugMenu:(BOOL)showsDebugMenu
{
	[self setBool:showsDebugMenu forKey:@"ShowsDebugMenu"];
}
- (BOOL)showsDebugMenu
{
	return [self boolForKey:@"ShowsDebugMenu"];
}

- (void)setAppendKanColleTag:(BOOL)appendKanColleTag
{
	[self setBool:appendKanColleTag forKey:@"appendKanColleTag"];
}
- (BOOL)appendKanColleTag
{
	return [self boolForKey:@"appendKanColleTag"];
}

- (void)setHideMaxKaryoku:(BOOL)hideMaxKaryoku
{
	[self setBool:hideMaxKaryoku forKey:@"hideMaxKaryoku"];
}
- (BOOL)hideMaxKaryoku
{
	return [self boolForKey:@"hideMaxKaryoku"];
}
- (void)setHideMaxLucky:(BOOL)hideMaxLucky
{
	[self setBool:hideMaxLucky forKey:@"hideMaxLucky"];
}
- (BOOL)hideMaxLucky
{
	return [self boolForKey:@"hideMaxLucky"];
}
- (void)setHideMaxRaisou:(BOOL)hideMaxRaisou
{
	[self setBool:hideMaxRaisou forKey:@"hideMaxRaisou"];
}
- (BOOL)hideMaxRaisou
{
	return [self boolForKey:@"hideMaxRaisou"];
}
- (void)setHideMaxSoukou:(BOOL)hideMaxSoukou
{
	[self setBool:hideMaxSoukou forKey:@"hideMaxSoukou"];
}
- (BOOL)hideMaxSoukou
{
	return [self boolForKey:@"hideMaxSoukou"];
}
- (void)setHideMaxTaiku:(BOOL)hideMaxTaiku
{
	[self setBool:hideMaxTaiku forKey:@"hideMaxTaiku"];
}
- (BOOL)hideMaxTaiku
{
	return [self boolForKey:@"hideMaxTaiku"];
}

- (void)setShowsPlanColor:(BOOL)showsPlanColor
{
	[self setBool:showsPlanColor forKey:@"showsPlanColor"];
}
- (BOOL)showsPlanColor
{
	return [self boolForKey:@"showsPlanColor"];
}
- (void)setPlan01Color:(NSColor *)plan01Color
{
	[self setKeyedArchiveObject:plan01Color forKey:@"plan01Color"];
}
- (NSColor *)plan01Color
{
	return [self keyedUnarchiveObject:@"plan01Color"];
}
- (void)setPlan02Color:(NSColor *)plan02Color
{
	[self setKeyedArchiveObject:plan02Color forKey:@"plan02Color"];
}
- (NSColor *)plan02Color
{
	return [self keyedUnarchiveObject:@"plan02Color"];
}
- (void)setPlan03Color:(NSColor *)plan03Color
{
	[self setKeyedArchiveObject:plan03Color forKey:@"plan03Color"];
}
- (NSColor *)plan03Color
{
	return [self keyedUnarchiveObject:@"plan03Color"];
}
- (void)setPlan04Color:(NSColor *)plan04Color
{
	[self setKeyedArchiveObject:plan04Color forKey:@"plan04Color"];
}
- (NSColor *)plan04Color
{
	return [self keyedUnarchiveObject:@"plan04Color"];
}
- (void)setPlan05Color:(NSColor *)plan05Color
{
	[self setKeyedArchiveObject:plan05Color forKey:@"plan05Color"];
}
- (NSColor *)plan05Color
{
	return [self keyedUnarchiveObject:@"plan05Color"];
}
- (void)setPlan06Color:(NSColor *)plan06Color
{
	[self setKeyedArchiveObject:plan06Color forKey:@"plan06Color"];
}
- (NSColor *)plan06Color
{
	return [self keyedUnarchiveObject:@"plan06Color"];
}

- (void)setMinimumColoredShipCount:(NSInteger)minimumColoredShipCount
{
	[self setInteger:minimumColoredShipCount forKey:@"minimumColoredShipCount"];
}
- (NSInteger)minimumColoredShipCount
{
	return [self integerForKey:@"minimumColoredShipCount"];
}

#pragma mark - Screenshot
- (void)setUseMask:(BOOL)useMask
{
	[self setBool:useMask forKey:@"useMask"];
}
- (BOOL)useMask
{
	return [self boolForKey:@"useMask"];
}

- (void)setScreenShotBorderWidth:(CGFloat)screenShotBorderWidth
{
	if(screenShotBorderWidth < 0 || screenShotBorderWidth > 20) return;
	
	[self setDouble:screenShotBorderWidth forKey:@"screenShotBorderWidth"];
}
- (CGFloat)screenShotBorderWidth
{
	CGFloat result = [self doubleForKey:@"screenShotBorderWidth"];
	
	if(result < 0) {
		[self setDouble:0 forKey:@"screenShotBorderWidth"];
		return 0;
	}
	if(result > 20) {
		[self setDouble:20 forKey:@"screenShotBorderWidth"];
		return 20;
	}
	
	return result;
}

- (void)setScreenShotSaveDirectory:(NSURL *)screenShotSaveDirectory
{
	[self setObject:screenShotSaveDirectory forKey:@"screenShotSaveDirectory"];
}
- (NSString *)screenShotSaveDirectory
{
	return [self objectForKey:@"screenShotSaveDirectory"];
}

- (void)setShowsListWindowAtScreenshot:(BOOL)showsListWindowAtScreenshot
{
	[self setBool:showsListWindowAtScreenshot forKey:@"showsListWindowAtScreenshot"];
}
- (BOOL)showsListWindowAtScreenshot
{
	return [self boolForKey:@"showsListWindowAtScreenshot"];
}

- (void)setScreenshotPreviewZoomValue:(NSNumber *)screenshotPreviewZoomValue
{
	[self setObject:screenshotPreviewZoomValue forKey:@"screenshotPreviewZoomValue"];
}
- (NSNumber *)screenshotPreviewZoomValue
{
	return [self objectForKey:@"screenshotPreviewZoomValue"];
}

- (void)setScreenshotEditorColumnCount:(NSInteger)screenshotEditorColumnCount
{
	[self setInteger:screenshotEditorColumnCount forKey:@"screenshotEditorColumnCount"];
}
- (NSInteger)screenshotEditorColumnCount
{
	return [self integerForKey:@"screenshotEditorColumnCount"];
}

- (void)setScrennshotEditorType:(NSInteger)scrennshotEditorType
{
	[self setInteger:scrennshotEditorType forKey:@"scrennshotEditorType"];
}
- (NSInteger)scrennshotEditorType
{
	return [self integerForKey:@"scrennshotEditorType"];
}

- (void)setScreenshotButtonSize:(NSControlSize)screenshotButtonSize
{
    [self setInteger:screenshotButtonSize forKey:@"screenshotButtonSize"];
}
- (NSControlSize)screenshotButtonSize
{
    return [self integerForKey:@"screenshotButtonSize"];
}

#pragma mark - Notify Sound
- (void)setPlayFinishMissionSound:(BOOL)playFinishMissionSound
{
	[self setBool:playFinishMissionSound forKey:@"playFinishMissionSound"];
}
- (BOOL)playFinishMissionSound
{
	return [self boolForKey:@"playFinishMissionSound"];
}
- (void)setPlayFinishNyukyoSound:(BOOL)playFinishNyukyoSound
{
	[self setBool:playFinishNyukyoSound forKey:@"playFinishNyukyoSound"];
}
- (BOOL)playFinishNyukyoSound
{
	return [self boolForKey:@"playFinishNyukyoSound"];
}
- (void)setPlayFinishKenzoSound:(BOOL)playFinishKenzoSound
{
	[self setBool:playFinishKenzoSound forKey:@"playFinishKenzoSound"];
}
- (BOOL)playFinishKenzoSound
{
	return [self boolForKey:@"playFinishKenzoSound"];
}


#pragma mark - Upgradable List
- (void)setShowLevelOneShipInUpgradableList:(BOOL)showLevelOneShipInUpgradableList
{
	[self setBool:showLevelOneShipInUpgradableList forKey:@"showLevelOneShipInUpgradableList"];
}
- (BOOL)showLevelOneShipInUpgradableList
{
	return [self boolForKey:@"showLevelOneShipInUpgradableList"];
}
- (void)setShowsExcludedShipInUpgradableList:(BOOL)showsExcludedShipInUpgradableList
{
	[self setBool:showsExcludedShipInUpgradableList forKey:@"showsExcludedShipInUpgradableList"];
}
- (BOOL)showsExcludedShipInUpgradableList
{
	return [self boolForKey:@"showsExcludedShipInUpgradableList"];
}


#pragma mark - Equipment List
- (void)setShowEquipmentType:(NSNumber *)showEquipmentType
{
	[self setObject:showEquipmentType forKey:@"showEquipmentType"];
}
- (NSNumber *)showEquipmentType
{
	return [self objectForKey:@"showEquipmentType"];
}

#pragma mark - FleetView
- (void)setFleetViewPosition:(NSInteger)fleetViewPosition
{
	[self setInteger:fleetViewPosition forKey:@"fleetViewPosition"];
}
- (NSInteger)fleetViewPosition
{
	return [self integerForKey:@"fleetViewPosition"];
}
- (void)setFleetViewShipOrder:(NSInteger)fleetViewShipOrder
{
	if(fleetViewShipOrder < 0 || fleetViewShipOrder > 1) return;
	[self setInteger:fleetViewShipOrder forKey:@"fleetViewShipOrder"];
}
- (NSInteger)fleetViewShipOrder
{
	return [self integerForKey:@"fleetViewShipOrder"];
}

- (void)setRepairTime:(NSDate *)repairTime
{
	[self setKeyedArchiveObject:repairTime forKey:@"repairTime"];
}
- (NSDate *)repairTime
{
	return [self keyedUnarchiveObject:@"repairTime"];
}

#pragma mark - combined view
- (void)setLastHasCombinedView:(BOOL)lastHasCombinedView
{
	[self setBool:lastHasCombinedView forKey:@"lastHasCombinedView"];
}
- (BOOL)lastHasCombinedView
{
	return [self boolForKey:@"lastHasCombinedView"];
}
- (void)setAutoCombinedView:(BOOL)autoCombinedView
{
	[self setBool:autoCombinedView forKey:@"autoCombinedView"];
}
- (BOOL)autoCombinedView
{
	return [self boolForKey:@"autoCombinedView"];
}
- (void)setUseSwipeChangeCombinedView:(BOOL)useSwipeChangeCombinedView
{
	[self setBool:useSwipeChangeCombinedView forKey:@"useSwipeChangeCombinedView"];
}
- (BOOL)useSwipeChangeCombinedView
{
	return [self boolForKey:@"useSwipeChangeCombinedView"];
}

#pragma mark - Old History Item Clean
- (void)setCleanOldHistoryItems:(BOOL)cleanOldHistoryItems
{
	[self setBool:cleanOldHistoryItems forKey:@"cleanOldHistoryItems"];
}
- (BOOL)cleanOldHistoryItems
{
	return [self boolForKey:@"cleanOldHistoryItems"];
}
- (void)setCleanSiceDays:(NSInteger)cleanSiceDays
{
	if(cleanSiceDays <= 0) return;
	[self setInteger:cleanSiceDays forKey:@"cleanSiceDays"];
}
- (NSInteger)cleanSiceDays
{
	return [self integerForKey:@"cleanSiceDays"];
}

#pragma mark - Notify time signal
- (void)setNotifyTimeSignal:(BOOL)notifyTimeSignal
{
    [self setBool:notifyTimeSignal forKey:@"notifyTimeSignal"];
}
- (BOOL)notifyTimeSignal
{
    return [self boolForKey:@"notifyTimeSignal"];
}
- (void)setNotifyTimeBeforeTimeSignal:(NSNumber *)notifyTimeBeforeTimeSignal
{
    NSInteger time = notifyTimeBeforeTimeSignal.integerValue;
    if(time < 1) {
        notifyTimeBeforeTimeSignal = @(1);
    }
    if(time > 59) {
        notifyTimeBeforeTimeSignal = @59;
    }
    [self setObject:notifyTimeBeforeTimeSignal forKey:@"notifyTimeBeforeTimeSignal"];
}
- (NSNumber *)notifyTimeBeforeTimeSignal
{
    return [self objectForKey:@"notifyTimeBeforeTimeSignal"];
}
- (void)setPlayNotifyTimeSignalSound:(BOOL)playNotifyTimeSignalSound
{
    [self setBool:playNotifyTimeSignalSound forKey:@"playNotifyTimeSignalSound"];
}
- (BOOL)playNotifyTimeSignalSound
{
    return [self boolForKey:@"playNotifyTimeSignalSound"];
}
@end
