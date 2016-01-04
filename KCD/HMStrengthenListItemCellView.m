//
//  HMStrengthenListItemCellView.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/13.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMStrengthenListItemCellView.h"

#import "HMStrengthenListItemView.h"


@interface HMStrengthenListItemCellView ()
@property (weak, nonatomic) IBOutlet HMStrengthenListItemView *itemBox;
@end

@implementation HMStrengthenListItemCellView

- (HMEnhancementListItem *)item
{
	return (HMEnhancementListItem *)self.objectValue;
}
- (void)setItem:(HMEnhancementListItem *)item
{
	self.objectValue = item;
}


+ (NSSet *)keyPathsForValuesAffectingSecondsShipList
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRequiredEquipment01
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRequiredEquipment02
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRequiredEquipment03
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingTargetEquipment
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRemodelEquipment
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingNeedsScrewString01
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingNeedsScrewString02
{
	return [NSSet setWithObjects:@"item", nil];
}
+ (NSSet *)keyPathsForValuesAffectingNeedsScrewString03
{
	return [NSSet setWithObjects:@"item", nil];
}

- (NSString *)secondsShipList
{
	NSArray *secondsShips = self.item.secondsShipNames;
	
	return [secondsShips componentsJoinedByString:@", "];
}
- (HMRequiredEquipment *)requiredEquipment01
{
	return self.item.requiredEquipments.requiredEquipment01;
}
- (HMRequiredEquipment *)requiredEquipment02
{
	return self.item.requiredEquipments.requiredEquipment02;
}
- (HMRequiredEquipment *)requiredEquipment03
{
	return self.item.requiredEquipments.requiredEquipment03;
}
- (NSString *)targetEquipment
{
	return self.item.targetEquipment;
}
- (NSString *)remodelEquipment
{
	return self.item.remodelEquipment;
}

- (NSString *)needsScrewString01
{
	NSInteger screw = self.requiredEquipment01.screw.integerValue;
	if(screw == 0) return nil;
	
	return [NSString stringWithFormat:@"%@/%@", self.requiredEquipment01.screw, self.requiredEquipment01.ensureScrew];
}
- (NSString *)needsScrewString02
{
	NSInteger screw = self.requiredEquipment02.screw.integerValue;
	if(screw == 0) return nil;
	
	return [NSString stringWithFormat:@"%@/%@", self.requiredEquipment02.screw, self.requiredEquipment02.ensureScrew];
}
- (NSString *)needsScrewString03
{
	NSInteger screw = self.requiredEquipment03.screw.integerValue;
	if(screw == 0) return nil;
	
	return [NSString stringWithFormat:@"%@/%@", self.requiredEquipment03.screw, self.requiredEquipment03.ensureScrew];
}
@end
