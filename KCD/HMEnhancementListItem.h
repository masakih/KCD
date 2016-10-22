//
//  HMEnhancementListItem.h
//  KCD
//
//  Created by Hori,Masaki on 2015/12/31.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, EquipmentType) {
	smallCaliberMainGun = 1,
	mediumCaliberMainGun,
	largeCaliberMainGun,
	SecondaryGun,
	torpedo = 8,
	smallRadar = 16,
	largeRadar,
	sonar = 24,
	depthCharge = 32,
	armorPiercingShell = 40,
	antiAircraftGun = 48,
	antiAircraftFireDirector = 56,
	searchlight = 64,
};

@interface HMRequiredEquipment : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *identifire;

@property (nonatomic, copy) NSString *currentLevelString;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSNumber *screw;
@property (nonatomic, copy) NSNumber *ensureScrew;

@property (readonly) NSString *numberString;

@end


@interface HMRequiredEquipmentSet : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *identifire;

@property (nonatomic, copy) NSArray<HMRequiredEquipment *> *requiredEquipments;


// for Cocoa Bindings
@property (readonly) HMRequiredEquipment *requiredEquipment01;
@property (readonly) HMRequiredEquipment *requiredEquipment02;
@property (readonly) HMRequiredEquipment *requiredEquipment03;

@end


@interface HMEnhancementListItem : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *identifire;

@property (nonatomic, copy) NSNumber *weekday;

@property (nonatomic, copy) NSNumber *equipmentType;

@property (nonatomic, copy) NSString *targetEquipment;
@property (nonatomic, copy) NSString *remodelEquipment;

@property (nonatomic, strong) HMRequiredEquipmentSet *requiredEquipments;

@property (nonatomic, copy) NSArray<NSString *> *secondsShipNames;


// for Cocoa Bindings
@property (readonly) NSString *secondsShipName01;
@property (readonly) NSString *secondsShipName02;
@property (readonly) NSString *secondsShipName03;


@end
