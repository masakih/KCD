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

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[[NSUserDefaults standardUserDefaults] registerDefaults:
		 @{
		   @"screenShotBorderWidth" : @(3.0),
		   }
		 ];
	});
}


- (void)setSlotItemSortDescriptors:(NSArray *)slotItemSortDescriptors
{
	if(slotItemSortDescriptors) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:slotItemSortDescriptors];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"slotItemSortKey"];
	}
}
- (NSArray *)slotItemSortDescriptors
{
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"slotItemSortKey"];
	if(data) {
		NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
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
- (void)setShipviewSortDescriptors:(NSArray *)shipviewSortDescriptors
{
	if(shipviewSortDescriptors) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shipviewSortDescriptors];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"shipviewsortdescriptor"];
	}
}
- (NSArray *)shipviewSortDescriptors
{
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"shipviewsortdescriptor"];
	if(data) {
		NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
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
	if(powerupSupportSortDecriptors) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:powerupSupportSortDecriptors];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"powerupsupportsortdecriptor"];
	}
}
- (NSArray *)powerupSupportSortDecriptors
{
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"powerupsupportsortdecriptor"];
	if(data) {
		NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
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
		[[NSUserDefaults standardUserDefaults] setObject:[prevReloadDate description] forKey:@"previousReloadDateString"];
	}
}
- (NSDate *)prevReloadDate
{
	NSString *dateString = [[NSUserDefaults standardUserDefaults] stringForKey:@"previousReloadDateString"];
	if(dateString) {
		return [NSDate dateWithString:dateString];
	}
	return nil;
}

- (void)setShowsDebugMenu:(BOOL)showsDebugMenu
{
	[[NSUserDefaults standardUserDefaults] setBool:showsDebugMenu forKey:@"ShowsDebugMenu"];
}
- (BOOL)showsDebugMenu
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowsDebugMenu"];
}

- (void)setAppendKanColleTag:(BOOL)appendKanColleTag
{
	[[NSUserDefaults standardUserDefaults] setBool:appendKanColleTag forKey:@"appendKanColleTag"];
}
- (BOOL)appendKanColleTag
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"appendKanColleTag"];
}

- (void)setHideMaxKaryoku:(BOOL)hideMaxKaryoku
{
	[[NSUserDefaults standardUserDefaults] setBool:hideMaxKaryoku forKey:@"hideMaxKaryoku"];
}
- (BOOL)hideMaxKaryoku
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxKaryoku"];
}
- (void)setHideMaxLucky:(BOOL)hideMaxLucky
{
	[[NSUserDefaults standardUserDefaults] setBool:hideMaxLucky forKey:@"hideMaxLucky"];
}
- (BOOL)hideMaxLucky
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxLucky"];
}
- (void)setHideMaxRaisou:(BOOL)hideMaxRaisou
{
	[[NSUserDefaults standardUserDefaults] setBool:hideMaxRaisou forKey:@"hideMaxRaisou"];
}
- (BOOL)hideMaxRaisou
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxRaisou"];
}
- (void)setHideMaxSoukou:(BOOL)hideMaxSoukou
{
	[[NSUserDefaults standardUserDefaults] setBool:hideMaxSoukou forKey:@"hideMaxSoukou"];
}
- (BOOL)hideMaxSoukou
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxSoukou"];
}
- (void)setHideMaxTaiku:(BOOL)hideMaxTaiku
{
	[[NSUserDefaults standardUserDefaults] setBool:hideMaxTaiku forKey:@"hideMaxTaiku"];
}
- (BOOL)hideMaxTaiku
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxTaiku"];
}

- (void)setShowsPlanColor:(BOOL)showsPlanColor
{
	[[NSUserDefaults standardUserDefaults] setBool:showsPlanColor forKey:@"showsPlanColor"];
}
- (BOOL)showsPlanColor
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"showsPlanColor"];
}


- (void)setMinimumColoredShipCount:(NSInteger)minimumColoredShipCount
{
	[[NSUserDefaults standardUserDefaults] setInteger:minimumColoredShipCount forKey:@"minimumColoredShipCount"];
}
- (NSInteger)minimumColoredShipCount
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"minimumColoredShipCount"];
}

- (void)setScreenShotBorderWidth:(CGFloat)screenShotBorderWidth
{
	if(screenShotBorderWidth < 0 || screenShotBorderWidth > 20) return;
	
	[[NSUserDefaults standardUserDefaults] setDouble:screenShotBorderWidth forKey:@"screenShotBorderWidth"];
}
- (CGFloat)screenShotBorderWidth
{
	CGFloat result = [[NSUserDefaults standardUserDefaults] doubleForKey:@"screenShotBorderWidth"];
	
	if(result < 0) {
		[[NSUserDefaults standardUserDefaults] setDouble:0 forKey:@"screenShotBorderWidth"];
		return 0;
	}
	if(result > 20) {
		[[NSUserDefaults standardUserDefaults] setDouble:20 forKey:@"screenShotBorderWidth"];
		return 20;
	}
	
	return result;
}

@end
