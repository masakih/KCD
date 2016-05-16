//
//  HMKCShipObject+Extensions.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterShipObject.h"
#import "HMKCMasterSType.h"

#import "HMKCMasterSlotItemObject.h"
#import "HMKCSlotItemObject+Extensions.h"

#import "HMServerDataStore.h"
#import "HMTemporaryDataStore.h"
#import "HMUserDefaults.h"


static NSArray *shortSTypeNames = nil;
static NSArray *levelUpExps = nil;

@implementation HMKCShipObject (Extensions)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSURL *url = [mainBundle URLForResource:@"STypeShortName" withExtension:@"plist"];
		NSArray *array = [[NSArray alloc] initWithContentsOfURL:url];
		if(!array) {
			NSLog(@"Can not load STypeShortName.plist.");
		}
		shortSTypeNames = [array copy];
		
		url = [mainBundle URLForResource:@"LevelUpExp" withExtension:@"plist"];
		array = [[NSArray alloc] initWithContentsOfURL:url];
		if(!array) {
			NSLog(@"Can not load LevelUpExp.plist.");
		}
		levelUpExps = [array copy];
	});
}


+ (NSSet *)keyPathsForValuesAffectingIsMaxKaryoku
{
	return [NSSet setWithObjects:@"karyoku_1", @"kyouka_0", nil];
}
- (NSNumber *)isMaxKaryoku
{
	[self willAccessValueForKey:@"master_ship"];
	[self willAccessValueForKey:@"karyoku_1"];
	[self willAccessValueForKey:@"kyouka_0"];
	NSInteger defaultValue = [self.master_ship.houg_0 integerValue];
	NSInteger maxValue = [self.karyoku_1 integerValue];
	NSInteger growth = [self.kyouka_0 integerValue];
	[self didAccessValueForKey:@"kyouka_0"];
	[self didAccessValueForKey:@"karyoku_1"];
	[self didAccessValueForKey:@"master_ship"];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxRaisou
{
	return [NSSet setWithObjects:@"raisou_1", @"kyouka_1", nil];
}
- (NSNumber *)isMaxRaisou
{
	[self willAccessValueForKey:@"master_ship"];
	[self willAccessValueForKey:@"raisou_1"];
	[self willAccessValueForKey:@"kyouka_1"];
	NSInteger defaultValue = [self.master_ship.raig_0 integerValue];
	NSInteger maxValue = [self.raisou_1 integerValue];
	NSInteger growth = [self.kyouka_1 integerValue];
	[self didAccessValueForKey:@"kyouka_1"];
	[self didAccessValueForKey:@"raisou_1"];
	[self didAccessValueForKey:@"master_ship"];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxTaiku
{
	return [NSSet setWithObjects:@"taiku_1", @"kyouka_2", nil];
}
- (NSNumber *)isMaxTaiku
{
	[self willAccessValueForKey:@"master_ship"];
	[self willAccessValueForKey:@"taiku_1"];
	[self willAccessValueForKey:@"kyouka_2"];
	NSInteger defaultValue = [self.master_ship.tyku_0 integerValue];
	NSInteger maxValue = [self.taiku_1 integerValue];
	NSInteger growth = [self.kyouka_2 integerValue];
	[self didAccessValueForKey:@"kyouka_2"];
	[self didAccessValueForKey:@"taiku_1"];
	[self didAccessValueForKey:@"master_ship"];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxSoukou
{
	return [NSSet setWithObjects:@"soukou_1", @"kyouka_3", nil];
}
- (NSNumber *)isMaxSoukou
{
	[self willAccessValueForKey:@"master_ship"];
	[self willAccessValueForKey:@"soukou_1"];
	[self willAccessValueForKey:@"kyouka_3"];
	NSInteger defaultValue = [self.master_ship.souk_0 integerValue];
	NSInteger maxValue = [self.soukou_1 integerValue];
	NSInteger growth = [self.kyouka_3 integerValue];
	[self didAccessValueForKey:@"kyouka_3"];
	[self didAccessValueForKey:@"soukou_1"];
	[self didAccessValueForKey:@"master_ship"];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxLucky
{
	return [NSSet setWithObjects:@"lucky_1", @"kyouka_4", nil];
}
- (NSNumber *)isMaxLucky
{
	[self willAccessValueForKey:@"master_ship"];
	[self willAccessValueForKey:@"lucky_1"];
	[self willAccessValueForKey:@"kyouka_4"];
	NSInteger defaultValue = [self.master_ship.luck_0 integerValue];
	NSInteger maxValue = [self.lucky_1 integerValue];
	NSInteger growth = [self.kyouka_4 integerValue];
	[self didAccessValueForKey:@"kyouka_4"];
	[self didAccessValueForKey:@"lucky_1"];
	[self didAccessValueForKey:@"master_ship"];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingName
{
	return [NSSet setWithObjects:@"ship_id", nil];
}
- (NSString *)name
{
	return [self.master_ship valueForKey:@"name"];
}

+ (NSSet *)keyPathsForValuesAffectingShortTypeName
{
	return [NSSet setWithObjects:@"ship_id", nil];
}
- (NSString *)shortTypeName
{
	[self willAccessValueForKey:@"master_ship"];
	NSNumber *idValue = self.master_ship.stype.id;
	[self didAccessValueForKey:@"master_ship"];
	if(!idValue || [idValue isKindOfClass:[NSNull class]]) return nil;
	
	if([shortSTypeNames count] < [idValue integerValue]) return nil;
	
	return shortSTypeNames[[idValue integerValue] - 1];
}

+ (NSSet *)keyPathsForValuesAffectingNext
{
	return [NSSet setWithObjects:@"exp", nil];
}
- (NSNumber *)next
{
	[self willAccessValueForKey:@"lv"];
	id lvValue = self.lv;
	[self didAccessValueForKey:@"lv"];
	[self willAccessValueForKey:@"exp"];
	id expValue = self.exp;
	[self didAccessValueForKey:@"exp"];
	
	NSUInteger currentLevel = [lvValue integerValue];
	if(currentLevel >= [levelUpExps count]) {
		return nil;
	}
	if(currentLevel == 99) return nil;
	
	NSUInteger nextExp = [[levelUpExps objectAtIndex:currentLevel] integerValue];
	if(currentLevel > 99) {
		nextExp += 1000000;
	}
	return @(nextExp - [expValue integerValue]);
}

+ (NSSet *)keyPathsForValuesAffectingStatus
{
	return [NSSet setWithObjects:@"nowhp", @"maxph", nil];
}
- (NSInteger)status
{
	[self willAccessValueForKey:@"maxhp"];
	[self willAccessValueForKey:@"nowhp"];
	NSInteger maxhp = [self.maxhp integerValue];
	CGFloat nowhp = [self.nowhp integerValue];
	[self didAccessValueForKey:@"nowhp"];
	[self didAccessValueForKey:@"maxhp"];
	
	CGFloat status = nowhp / maxhp;
	if(status <= 0.25) {
		return 3;
	}
	if(status <= 0.5) {
		return 2;
	}
	if(status <= 0.75) {
		return 1;
		
	}
	return 0;
}

+ (NSSet *)keyPathsForValuesAffectingStatusColor
{
	return [NSSet setWithObjects:@"status", nil];
}
- (NSColor *)statusColor
{
	[self willAccessValueForKey:@"maxhp"];
	[self willAccessValueForKey:@"nowhp"];
	NSInteger maxhp = [self.maxhp integerValue];
	CGFloat nowhp = [self.nowhp integerValue];
	[self didAccessValueForKey:@"nowhp"];
	[self didAccessValueForKey:@"maxhp"];
	
	CGFloat status = nowhp / maxhp;
	if(status <= 0.25) {
		return [NSColor redColor];
	}
	if(status <= 0.5) {
		return [NSColor orangeColor];
	}
	if(status <= 0.75) {
		return [NSColor yellowColor];
		
	}
	return [NSColor controlTextColor];
}

+ (NSSet *)keyPathsForValuesAffectingConditionColor
{
	return [NSSet setWithObjects:@"cond", nil];
}
- (NSColor *)conditionColor
{
	return [NSColor controlTextColor];
}

- (NSColor *)planColor
{
	if(!HMStandardDefaults.showsPlanColor) return [NSColor controlTextColor];
	
	[self willAccessValueForKey:@"sally_area"];
	NSInteger planType = [self.sally_area integerValue];
	[self didAccessValueForKey:@"sally_area"];
	if(planType == 1) return HMStandardDefaults.plan01Color;
	if(planType == 2) return HMStandardDefaults.plan02Color;
	if(planType == 3) return HMStandardDefaults.plan03Color;
	if(planType == 4) return HMStandardDefaults.plan04Color;
	if(planType == 5) return HMStandardDefaults.plan05Color;
	if(planType == 6) return HMStandardDefaults.plan06Color;
	return [NSColor controlTextColor];
}


- (NSNumber *)maxFuel
{
	[self willAccessValueForKey:@"master_ship"];
	NSNumber *number = self.master_ship.fuel_max;
	[self didAccessValueForKey:@"master_ship"];
	return number;
}
- (NSNumber *)maxBull
{
	[self willAccessValueForKey:@"master_ship"];
	NSNumber *number = self.master_ship.bull_max;
	[self didAccessValueForKey:@"master_ship"];
	return number;
}

- (NSNumber *)upgradeLevel
{
	[self willAccessValueForKey:@"master_ship"];
	NSNumber *number = self.master_ship.afterlv;
	[self didAccessValueForKey:@"master_ship"];
	return number;
}
+ (NSSet *)keyPathsForValuesAffectingUpgradeExp
{
	return [NSSet setWithObjects:@"exp", nil];
}
- (NSNumber *)upgradeExp
{
	NSInteger upgradeLevtl = [self.upgradeLevel integerValue];
	if(upgradeLevtl <= 0) return nil;
	
	NSInteger upgradeExp = [[levelUpExps objectAtIndex:upgradeLevtl - 1] integerValue];
	NSInteger exp = [self.exp integerValue];
	upgradeExp -= exp;
	if(upgradeExp < 0) {
		upgradeExp = 0;
	}
	return @(upgradeExp);
}

- (NSNumber *)totalEquipment
{
	NSInteger total = 0;
	[self willAccessValueForKey:@"master_ship"];
	total += self.master_ship.maxeq_0.integerValue;
	total += self.master_ship.maxeq_1.integerValue;
	total += self.master_ship.maxeq_2.integerValue;
	total += self.master_ship.maxeq_3.integerValue;
	total += self.master_ship.maxeq_4.integerValue;
	[self didAccessValueForKey:@"master_ship"];
	return @(total);
}

+ (NSSet *)keyPathsForValuesAffectingSeiku
{
	return [NSSet setWithObjects:
			@"slot_0", @"slot_1", @"slot_2", @"slot_3", @"slot_4",
			@"onslot_0", @"onslot_1", @"onslot_2", @"onslot_3", @"onslot_4",
			nil];
}

- (HMKCSlotItemObject *)slotItemAtIndex:(NSUInteger)index
{
	HMServerDataStore *store = [HMServerDataStore defaultManager];

	NSString *key = [NSString stringWithFormat:@"slot_%ld", index];
	NSNumber *itemId = [self valueForKey:key];
	if(itemId.integerValue == -1) return nil;
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"SlotItem"
											error:&error
								  predicateFormat:@"id = %@", itemId];
	if(array.count == 0) return nil;
	HMKCSlotItemObject *slotItem = array[0];
	return slotItem;
}

- (CGFloat)floatSeikuWithSlotIndex:(NSUInteger)index
{
	NSArray *effectiveTypes = @[@6, @7, @8, @11, @45];
	
	CGFloat totalSeiku = 0;
	HMKCSlotItemObject *slotItem = [self slotItemAtIndex:index];
	HMKCMasterSlotItemObject *master = slotItem.master_slotItem;
	NSNumber *type2 = master.type_2;
	if(![effectiveTypes containsObject:type2]) {
		return 0.0;
	}
	
	NSString *key = [NSString stringWithFormat:@"onslot_%ld", index];
	NSNumber *itemCountValue = [self valueForKey:key];
	NSNumber *taikuValue = master.tyku;
	NSInteger itemCount = [itemCountValue integerValue];
	NSInteger taiku = [taikuValue integerValue];
	if(itemCount && taiku) {
		totalSeiku += taiku * sqrt(itemCount);
	}
	
	return totalSeiku;
}
- (CGFloat)extraSeikuWithSlotIndex:(NSUInteger)index
{
	NSArray *fighterTypes = @[@6];
	NSArray *bomberTypes = @[@7];
	NSArray *attackerTypes = @[@8];
	NSArray *floatplaneBomberTypes = @[@11];
	NSArray *floatplaneFighterTypes = @[@45];
	
	const CGFloat fighterBonus[] = {0, 0, 2, 5, 9, 14, 14, 22};
	const CGFloat bomberBonus[] = {0, 0, 0, 0, 0, 0, 0, 0};
	const CGFloat attackerBonus[] = {0, 0, 0, 0, 0, 0, 0, 0};
	const CGFloat floatplaneBomberBonus[] = {0, 0, 1, 1, 1, 3, 3, 6};
	const CGFloat floatplaneFighterBonus[] = {0, 0, 2, 5, 9, 14, 14, 22};
	//            sqrt 0, 1,     2.5,   4,     5.5,   7,     8.5,   10
	const CGFloat bonus[] = {0, 1.000, 1.581, 2.000, 2.345, 2.645, 2.915, 3.162};
	
	CGFloat extraSeiku = 0;
	
	NSString *key = [NSString stringWithFormat:@"onslot_%ld", index];
	NSNumber *itemCountValue = [self valueForKey:key];
	NSInteger itemCount = [itemCountValue integerValue];
	if(itemCount == 0) return 0.0;
	
	HMKCSlotItemObject *slotItem = [self slotItemAtIndex:index];
	NSInteger airLevel = slotItem.alv.integerValue;
	
	const CGFloat *typeBonus = NULL;
	
	HMKCMasterSlotItemObject *master = slotItem.master_slotItem;
	NSNumber *type2 = master.type_2;
	if([fighterTypes containsObject:type2]) {
		typeBonus = fighterBonus;
	}
	if([bomberTypes containsObject:type2]) {
		typeBonus = bomberBonus;
	}
	if([attackerTypes containsObject:type2]) {
		typeBonus = attackerBonus;
	}
	if([floatplaneBomberTypes containsObject:type2]) {
		typeBonus = floatplaneBomberBonus;
	}
	if([floatplaneFighterTypes containsObject:type2]) {
		typeBonus = floatplaneFighterBonus;
	}
	if(!typeBonus) return 0.0;
	
	extraSeiku += typeBonus[airLevel] + bonus[airLevel];
	
	return extraSeiku;
}

- (CGFloat)seikuWithSlotIndex:(NSUInteger)index
{
	NSInteger seiku = [self floatSeikuWithSlotIndex:index] + [self extraSeikuWithSlotIndex:index];
	return seiku;
}

- (NSNumber *)seiku
{
	NSInteger seiku = 0;
	for(NSInteger i = 0; i < 5; i++) {
		seiku += [self floatSeikuWithSlotIndex:i];
	}
	return @(seiku);
}
- (NSNumber *)extraSeiku
{
	NSInteger extraSeiku = 0;
	for(NSInteger i = 0; i < 5; i++) {
		extraSeiku += [self extraSeikuWithSlotIndex:i];
	}
	
	return @(extraSeiku);
}


+ (NSSet *)keyPathsForValuesAffectingTotalSeiku
{
	return [NSSet setWithObjects:@"seiku", @"extraSeiku", nil];
}
- (NSNumber *)totalSeiku
{
	NSInteger totalSeiku = 0;
	for(NSInteger i = 0; i < 5; i++) {
		totalSeiku += [self seikuWithSlotIndex:i];
	}
	return @(totalSeiku);
}

+ (NSSet *)keyPathsForValuesAffectingTotalDrums
{
	return [NSSet setWithObjects:
			@"slot_0", @"slot_1", @"slot_2", @"slot_3", @"slot_4",
			nil];
}

- (NSNumber *)totalDrums
{
	NSInteger totalBuckets = 0;
	for(NSInteger i = 0; i < 5; i++) {
		HMKCSlotItemObject *slotItem = [self slotItemAtIndex:i];
		NSNumber *masterID = slotItem.slotitem_id;
		if([masterID isEqualToNumber:@(75)]) {
			totalBuckets++;
		}
	}
	
	return @(totalBuckets);
}

- (NSNumber *)guardEscaped
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore defaultManager];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"GuardEscaped"
											error:&error
								  predicateFormat:@"shipID = %@ AND ensured = TRUE", self.id];
	if(error) {
		NSLog(@"GuardEscaped is invalid. error -> %@", error);
		return @NO;
	}
	if(!array) return @NO;
	
	return array.count == 0 ? @NO : @YES;
}

+ (NSSet *)keyPathsForValuesAffectingSteelRequiredInRepair
{
	return [NSSet setWithObject:@"nowhp"];
}
- (NSNumber *)steelRequiredInRepair
{
	NSInteger steel = self.master_ship.fuel_max.integerValue * 0.06 * (self.maxhp.integerValue - self.nowhp.integerValue);
	return @(steel);
}

+ (NSSet *)keyPathsForValuesAffectingFuelRequiredInRepair
{
	return [NSSet setWithObject:@"nowhp"];
}
- (NSNumber *)fuelRequiredInRepair
{
	NSInteger fuel = self.master_ship.fuel_max.integerValue * 0.032 * (self.maxhp.integerValue - self.nowhp.integerValue);
	return @(fuel);
}

@end
