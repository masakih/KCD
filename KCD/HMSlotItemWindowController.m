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
	[self.slotItemController fetchWithRequest:nil merge:YES error:NULL];
	[self.slotItemController setSortDescriptors:HMStandardDefaults.slotItemSortDescriptors];
	[self.slotItemController addObserver:self
						  forKeyPath:NSSortDescriptorsBinding
							 options:0
							 context:NULL];
	
	// refresh filter
	self.showEquipmentType = self.showEquipmentType;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:NSSortDescriptorsBinding]) {
		HMStandardDefaults.slotItemSortDescriptors = [self.slotItemController sortDescriptors];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
			return [NSPredicate predicateWithFormat:@"equippedShip.lv = NULL"];
			break;
		case 1:
			return [NSPredicate predicateWithFormat:@"equippedShip.lv != NULL"];
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
