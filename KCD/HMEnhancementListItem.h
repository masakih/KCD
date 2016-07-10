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

@property (copy, nonatomic) NSString *identifire;

@property (copy, nonatomic) NSString *currentLevelString;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSNumber *number;
@property (copy, nonatomic) NSNumber *screw;
@property (copy, nonatomic) NSNumber *ensureScrew;

@property (readonly) NSString *numberString;

@end


@interface HMRequiredEquipmentSet : NSObject <NSCoding, NSCopying>

@property (copy, nonatomic) NSString *identifire;

@property (copy, nonatomic) NSArray<HMRequiredEquipment *> *requiredEquipments;


// for Cocoa Bindings
@property (readonly) HMRequiredEquipment *requiredEquipment01;
@property (readonly) HMRequiredEquipment *requiredEquipment02;
@property (readonly) HMRequiredEquipment *requiredEquipment03;

@end


@interface HMEnhancementListItem : NSObject <NSCoding, NSCopying>

@property (copy, nonatomic) NSString *identifire;

@property (copy, nonatomic) NSNumber *weekday;

@property (copy, nonatomic) NSNumber *equipmentType;

@property (copy, nonatomic) NSString *targetEquipment;
@property (copy, nonatomic) NSString *remodelEquipment;

@property (strong, nonatomic) HMRequiredEquipmentSet *requiredEquipments;

@property (strong, nonatomic) NSArray<NSString *> *secondsShipNames;


// for Cocoa Bindings
@property (readonly) NSString *secondsShipName01;
@property (readonly) NSString *secondsShipName02;
@property (readonly) NSString *secondsShipName03;


@end
