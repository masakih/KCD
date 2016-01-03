//
//  HMStrengthenListItemCellView.h
//  KCD
//
//  Created by Hori,Masaki on 2015/06/13.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMEnhancementListItem.h"

typedef NS_ENUM(NSUInteger, HMStrengthenListItemBackgoudColorType) {
	nomal,
	alternate,
};

@interface HMStrengthenListItemCellView : NSTableCellView

@property (nonatomic) HMStrengthenListItemBackgoudColorType backgroundColorType;

@property (strong) HMEnhancementListItem *item;

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
