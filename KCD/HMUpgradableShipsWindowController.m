//
//  HMUpgradableShipsWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/26.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMUpgradableShipsWindowController.h"

#import "HMServerDataStore.h"
#import "HMUserDefaults.h"

@interface HMUpgradableShipsWindowController ()

@end

@implementation HMUpgradableShipsWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}


+ (NSSet *)keyPathsForValuesAffectingFilterPredicate
{
	return [NSSet setWithObject:@"showLevelOneShipInUpgradableList"];
}
- (void)setShowLevelOneShipInUpgradableList:(BOOL)showLevelOneShipInUpgradableList
{
	HMStandardDefaults.showLevelOneShipInUpgradableList = showLevelOneShipInUpgradableList;
}
- (BOOL)showLevelOneShipInUpgradableList
{
	return HMStandardDefaults.showLevelOneShipInUpgradableList;
}

- (NSPredicate *)filterPredicate
{
	if(!HMStandardDefaults.showLevelOneShipInUpgradableList) {
		return [NSPredicate predicateWithFormat:@"lv != 1"];
	}
	return nil;
}

@end
