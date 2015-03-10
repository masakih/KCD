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

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		HMStandardDefaults = [self new];
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

- (void)setPrevReloadDate:(NSDate *)prevReloadDate
{
	if(prevReloadDate) {
		[self setObject:[prevReloadDate description] forKey:@"previousReloadDateString"];
	}
}
- (NSDate *)prevReloadDate
{
	NSString *dateString = [self stringForKey:@"previousReloadDateString"];
	if(dateString) {
		return [NSDate dateWithString:dateString];
	}
	return nil;
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
	if(fleetViewPosition < 0 || fleetViewPosition > 2) return;
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
@end
