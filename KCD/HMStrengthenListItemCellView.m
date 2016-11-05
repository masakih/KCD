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
@property (nonatomic, weak) IBOutlet HMStrengthenListItemView *itemBox;

// for Cocoa Bindings
@property (readonly) NSString *secondsShipList;
@property (readonly) HMRequiredEquipment *requiredEquipment01;
@property (readonly) HMRequiredEquipment *requiredEquipment02;
@property (readonly) HMRequiredEquipment *requiredEquipment03;
@property (readonly) NSString *targetEquipment;
@property (readonly) NSString *remodelEquipment;

@property (readonly) NSString *needsScrewString01;
@property (readonly) NSString *needsScrewString02;
@property (readonly) NSString *needsScrewString03;
@end

@implementation HMStrengthenListItemCellView

- (HMEnhancementListItem *)item
{
	return (HMEnhancementListItem *)self.objectValue;
}

+ (NSSet *)keyPathsForValuesAffectingSecondsShipList
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRequiredEquipment01
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRequiredEquipment02
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRequiredEquipment03
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingTargetEquipment
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingRemodelEquipment
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingNeedsScrewString01
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingNeedsScrewString02
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
}
+ (NSSet *)keyPathsForValuesAffectingNeedsScrewString03
{
	return [NSSet setWithObjects:@"item", @"objectValue", nil];
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

NSString *needsScrewString(NSNumber *screwNumber, NSNumber *ensureScrewNumber)
{
    NSString *screwString = @"";
    NSString *ensureScrewString = @"";
    
    NSInteger screw = screwNumber.integerValue;
    if(screw == 0) return nil;
    if(screw == -1) {
        screwString = @"-";
    } else {
        screwString = [NSString stringWithFormat:@"%ld", screw];
    }
    
    NSInteger ensureScrew = ensureScrewNumber.integerValue;
    if(ensureScrew == -1) {
        ensureScrewString = @"-";
    } else {
        ensureScrewString = [NSString stringWithFormat:@"%ld", ensureScrew];
    }
    
    return [NSString stringWithFormat:@"%@/%@", screwString, ensureScrewString];
}

- (NSString *)needsScrewString01
{
    return needsScrewString(self.requiredEquipment01.screw, self.requiredEquipment01.ensureScrew);
}
- (NSString *)needsScrewString02
{
	return needsScrewString(self.requiredEquipment02.screw, self.requiredEquipment02.ensureScrew);
}
- (NSString *)needsScrewString03
{
    return needsScrewString(self.requiredEquipment03.screw, self.requiredEquipment03.ensureScrew);
}
@end
