//
//  HMSlotItemWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMSlotItemWindowController.h"
#import "HMUserDefaults.h"

#import "HMServerDataStore.h"

@interface HMSlotItemWindowController ()

@end

@implementation HMSlotItemWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (void)awakeFromNib
{
	// refresh filter
	self.showEquipmentType = self.showEquipmentType;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

+ (NSSet *)keyPathsForValuesAffectingFilterPredicate
{
	return [NSSet setWithObject:@"showEquipmentType"];
}
+ (NSSet *)keyPathsForValuesAffectingShowEquipmentTypeTitle
{
	return [NSSet setWithObject:@"showEquipmentType"];
}
- (void)setShowEquipmentType:(NSNumber *)showEquipmentType
{
	HMStandardDefaults.showEquipmentType = showEquipmentType;
	self.slotItemController.fetchPredicate = self.filterPredicate;
}
- (NSNumber *)showEquipmentType
{
	return HMStandardDefaults.showEquipmentType;
}

- (NSPredicate *)filterPredicate
{
	NSInteger type = HMStandardDefaults.showEquipmentType.integerValue;
	switch (type) {
		case -1:
			break;
		case 0:
			return [NSPredicate predicateWithFormat:@"equippedShip.lv = NULL && extraEquippedShip.lv = NULL"];
			break;
		case 1:
			return [NSPredicate predicateWithFormat:@"equippedShip.lv != NULL || extraEquippedShip.lv != NULL"];
			break;
		default:
			break;
	}
	return nil;
}
- (NSString *)showEquipmentTypeTitle
{
	NSInteger type = HMStandardDefaults.showEquipmentType.integerValue;
	switch (type) {
		case -1:
			return NSLocalizedString(@"All", @"show equipment type All");
			break;
		case 0:
			return NSLocalizedString(@"Unequiped", @"show equipment type Unequiped");
			break;
		case 1:
			return NSLocalizedString(@"Equiped", @"show equipment type Equiped");
			break;
		default:
			break;
	}
	return @"";
}

@end
