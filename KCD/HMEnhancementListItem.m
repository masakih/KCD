//
//  HMEnhancementListItem.m
//  KCD
//
//  Created by Hori,Masaki on 2015/12/31.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMEnhancementListItem.h"

@implementation HMRequiredEquipment
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	self.identifire = [aDecoder decodeObjectForKey:@"HMRequiredEquipmentIdentifier"];
	self.currentLevelString = [aDecoder decodeObjectForKey:@"currentLevelString"];
	self.name = [aDecoder decodeObjectForKey:@"name"];
	self.number = [aDecoder decodeObjectForKey:@"number"];
	self.screw = [aDecoder decodeObjectForKey:@"screw"];
	self.ensureScrew = [aDecoder decodeObjectForKey:@"ensureScrew"];
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.identifire forKey:@"HMRequiredEquipmentIdentifier"];
	[aCoder encodeObject:self.currentLevelString forKey:@"currentLevelString"];
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.number forKey:@"number"];
	[aCoder encodeObject:self.screw forKey:@"screw"];
	[aCoder encodeObject:self.ensureScrew forKey:@"ensureScrew"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	HMRequiredEquipment *obj = [HMRequiredEquipment new];
	obj.identifire = self.identifire;
	obj.currentLevelString = self.currentLevelString;
	obj.name = self.name;
	obj.number = self.number;
	obj.screw = self.screw;
	obj.ensureScrew = self.ensureScrew;
	
	return obj;
}

- (NSString *)numberString
{
	NSNumber *number = self.number;
	if(!number) return nil;
	if(number.integerValue == -1) return @"-";
	
	return [NSString stringWithFormat:@"%@", number];
}

- (id)description
{
	NSString *format =
	@"{\n"
	@"identifier = %@,\n"
	@"currentLevelString = %@,\n"
	@"name = %@,\n"
	@"number = %@,\n"
	@"screw = %@,\n"
	@"ensureScrew = %@,\n"
	@"}";
	
	return [NSString stringWithFormat:format, _identifire, _currentLevelString, _name, _number, _screw, _ensureScrew];
}

@end

@implementation HMRequiredEquipmentSet
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	self.identifire = [aDecoder decodeObjectForKey:@"HMRequiredEquipmentSetIdentifier"];
	self.requiredEquipments = [aDecoder decodeObjectForKey:@"requiredEquipments"];
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.identifire forKey:@"HMRequiredEquipmentSetIdentifier"];
	[aCoder encodeObject:self.requiredEquipments forKey:@"requiredEquipments"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	HMRequiredEquipmentSet *obj = [HMRequiredEquipmentSet new];
	obj.identifire = self.identifire;
	obj.requiredEquipments = self.requiredEquipments;
	
	return obj;
}

- (id)description
{
	return [NSString stringWithFormat:@"{identifier = %@,\nrequiredEquipments = %@\n}", _identifire, _requiredEquipments];
}

- (HMRequiredEquipment *)requiredEquipment01
{
	if(self.requiredEquipments.count > 0) return self.requiredEquipments[0];
	return nil;
}
- (HMRequiredEquipment *)requiredEquipment02
{
	if(self.requiredEquipments.count > 1) return self.requiredEquipments[1];
	return nil;
}
- (HMRequiredEquipment *)requiredEquipment03
{
	if(self.requiredEquipments.count > 2) return self.requiredEquipments[2];
	return nil;
}
@end

@implementation HMEnhancementListItem
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	self.identifire = [aDecoder decodeObjectForKey:@"HMEnhancementListItemIdentifier"];
	self.weekday = [aDecoder decodeObjectForKey:@"weekday"];
	self.equipmentType = [aDecoder decodeObjectForKey:@"equipmentType"];
	self.targetEquipment = [aDecoder decodeObjectForKey:@"targetEquipment"];
	self.remodelEquipment = [aDecoder decodeObjectForKey:@"remodelEquipment"];
	self.requiredEquipments = [aDecoder decodeObjectForKey:@"requiredEquipments"];
	self.secondsShipNames = [aDecoder decodeObjectForKey:@"secondsShipNames"];
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.identifire forKey:@"HMEnhancementListItemIdentifier"];
	[aCoder encodeObject:self.weekday forKey:@"weekday"];
	[aCoder encodeObject:self.equipmentType forKey:@"equipmentType"];
	[aCoder encodeObject:self.targetEquipment forKey:@"targetEquipment"];
	[aCoder encodeObject:self.remodelEquipment forKey:@"remodelEquipment"];
	[aCoder encodeObject:self.requiredEquipments forKey:@"requiredEquipments"];
	[aCoder encodeObject:self.secondsShipNames forKey:@"secondsShipNames"];
}
- (instancetype)copyWithZone:(NSZone *)zone
{
	HMEnhancementListItem *obj = [HMEnhancementListItem new];
	obj.identifire = self.identifire;
	obj.weekday = self.weekday;
	obj.equipmentType = self.equipmentType;
	obj.targetEquipment = self.targetEquipment;
	obj.remodelEquipment = self.remodelEquipment;
	obj.requiredEquipments = [self.requiredEquipments copy];
	obj.secondsShipNames = [self.secondsShipNames copy];
	
	return obj;
}

- (id)description
{
	NSString *format =
	@"{\n"
	@"identifier = %@,\n"
	@"weekday = %@,\n"
	@"equipmentType = %@,\n"
	@"targetEquipment = %@,\n"
	@"remodelEquipment = %@,\n"
	@"requiredEquipments = %@,\n"
	@"secondsShipNames = %@,\n"
	@"}";
	
	return [NSString stringWithFormat:format,
			_identifire, _weekday, _equipmentType, _targetEquipment,
			_remodelEquipment, _requiredEquipments, _secondsShipNames];
}


- (NSString *)secondsShipName01
{
	if(self.secondsShipNames.count > 0) return self.secondsShipNames[0];
	return nil;
}
- (NSString *)secondsShipName02
{
	if(self.secondsShipNames.count > 1) return self.secondsShipNames[1];
	return nil;
}
- (NSString *)secondsShipName03
{
	if(self.secondsShipNames.count > 2) return self.secondsShipNames[2];
	return nil;
}
@end
