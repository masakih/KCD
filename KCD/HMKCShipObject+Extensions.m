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
	NSInteger defaultValue = [self.master_ship.houg_0 integerValue];
	NSInteger maxValue = [self.karyoku_1 integerValue];
	NSInteger growth = [self.kyouka_0 integerValue];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxRaisou
{
	return [NSSet setWithObjects:@"raisou_1", @"kyouka_1", nil];
}
- (NSNumber *)isMaxRaisou
{
	NSInteger defaultValue = [self.master_ship.raig_0 integerValue];
	NSInteger maxValue = [self.raisou_1 integerValue];
	NSInteger growth = [self.kyouka_1 integerValue];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxTaiku
{
	return [NSSet setWithObjects:@"taiku_1", @"kyouka_2", nil];
}
- (NSNumber *)isMaxTaiku
{
	NSInteger defaultValue = [self.master_ship.tyku_0 integerValue];
	NSInteger maxValue = [self.taiku_1 integerValue];
	NSInteger growth = [self.kyouka_2 integerValue];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxSoukou
{
	return [NSSet setWithObjects:@"soukou_1", @"kyouka_3", nil];
}
- (NSNumber *)isMaxSoukou
{
	NSInteger defaultValue = [self.master_ship.souk_0 integerValue];
	NSInteger maxValue = [self.soukou_1 integerValue];
	NSInteger growth = [self.kyouka_3 integerValue];
	
	return @(defaultValue + growth >= maxValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsMaxLucky
{
	return [NSSet setWithObjects:@"lucky_1", @"kyouka_4", nil];
}
- (NSNumber *)isMaxLucky
{
	NSInteger defaultValue = [self.master_ship.luck_0 integerValue];
	NSInteger maxValue = [self.lucky_1 integerValue];
	NSInteger growth = [self.kyouka_4 integerValue];
	
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
	NSNumber *idValue = self.master_ship.stype.id;
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
	id lvValue = self.lv;
	id expValue = self.exp;
	
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
	NSInteger maxhp = [self.maxhp integerValue];
	CGFloat nowhp = [self.nowhp integerValue];
	
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
	NSInteger maxhp = [self.maxhp integerValue];
	CGFloat nowhp = [self.nowhp integerValue];
	
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
	
	NSInteger planType = [self.sally_area integerValue];

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
	NSNumber *number = self.master_ship.fuel_max;
	return number;
}
- (NSNumber *)maxBull
{
	NSNumber *number = self.master_ship.bull_max;
	return number;
}

- (NSNumber *)upgradeLevel
{
	NSNumber *number = self.master_ship.afterlv;
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
	total += self.master_ship.maxeq_0.integerValue;
	total += self.master_ship.maxeq_1.integerValue;
	total += self.master_ship.maxeq_2.integerValue;
	total += self.master_ship.maxeq_3.integerValue;
	total += self.master_ship.maxeq_4.integerValue;
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

- (NSArray *)effectiveTypes
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@6, @7, @8, @11, @45];
	});
	
	return array;
}

- (NSInteger)floatSeikuWithSlotIndex:(NSUInteger)index
{
	CGFloat totalSeiku = 0;
	HMKCSlotItemObject *slotItem = [self slotItemAtIndex:index];
	HMKCMasterSlotItemObject *master = slotItem.master_slotItem;
	NSNumber *type2 = master.type_2;
	if(![self.effectiveTypes containsObject:type2]) {
		return 0.0;
	}
	
	NSString *key = [NSString stringWithFormat:@"onslot_%ld", index];
	NSNumber *itemCountValue = [self valueForKey:key];
	NSNumber *taikuValue = master.tyku;
	NSInteger itemCount = [itemCountValue integerValue];
	CGFloat taiku = [taikuValue integerValue];
	
	if(itemCount != 0 && (NSInteger)taiku != 0) {
		CGFloat rate = 0.2;
		if([self.bomberTypes containsObject:type2]) {
			rate = 0.25;
		}
		taiku += slotItem.level.integerValue * rate;
		
		totalSeiku += taiku * sqrt(itemCount);
	}
	
	return totalSeiku;
}

- (NSArray *)fighterTypes
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@6];
	});
	
	return array;
}
- (NSArray *)bomberTypes
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@7];
	});
	
	return array;
}
- (NSArray *)attackerTypes
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@8];
	});
	
	return array;
}
- (NSArray *)floatplaneBomberTypes
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@11];
	});
	
	return array;
}
- (NSArray *)floatplaneFighterTypes
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@45];
	});
	
	return array;
}
- (NSArray *)jetFighter
{
    static NSArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = @[@56];
    });
    
    return array;
}
- (NSArray *)jetBomberTypes
{
    static NSArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = @[@57];
    });
    
    return array;
}
- (NSArray *)jetAttacker
{
    static NSArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = @[@58];
    });
    
    return array;
}
- (NSInteger)extraSeikuWithSlotIndex:(NSUInteger)index
{
	const CGFloat fighterBonus[] = {0, 0, 2, 5, 9, 14, 14, 22};
	const CGFloat bomberBonus[] = {0, 0, 0, 0, 0, 0, 0, 0};
	const CGFloat attackerBonus[] = {0, 0, 0, 0, 0, 0, 0, 0};
	const CGFloat floatplaneBomberBonus[] = {0, 0, 1, 1, 1, 3, 3, 6};
	const CGFloat floatplaneFighterBonus[] = {0, 0, 2, 5, 9, 14, 14, 22};
//    const CGFloat jetFighterBonus[] = {0, 0, 0, 0, 0, 0, 0, 0}; 未実装
    const CGFloat jetBomberBonus[] = {0, 0, 0, 0, 0, 0, 0, 0};
//    const CGFloat jetAttackerBonus[] = {0, 0, 0, 0, 0, 0, 0, 0}; 未実装
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
	if([self.fighterTypes containsObject:type2]) {
		typeBonus = fighterBonus;
	}
	if([self.bomberTypes containsObject:type2]) {
		typeBonus = bomberBonus;
	}
	if([self.attackerTypes containsObject:type2]) {
		typeBonus = attackerBonus;
	}
	if([self.floatplaneBomberTypes containsObject:type2]) {
		typeBonus = floatplaneBomberBonus;
	}
	if([self.floatplaneFighterTypes containsObject:type2]) {
		typeBonus = floatplaneFighterBonus;
	}
    if([self.jetBomberTypes containsObject:type2]) {
        typeBonus = jetBomberBonus;
    }
	if(!typeBonus) return 0.0;
	
	extraSeiku += typeBonus[airLevel] + bonus[airLevel];
	
	return extraSeiku;
}

- (NSInteger)seikuWithSlotIndex:(NSUInteger)index
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



// Carrier-based plane count and max count.
- (NSArray *)planeItemTypes
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@6, @7, @8, @9, @10, @11, @25, @26, @41, @45, @56, @57, @58, @59];
	});
	
	return array;
}
- (NSString *)planeStringForSlot:(NSNumber *)slot
{
	NSString *slotKey = [NSString stringWithFormat:@"slot_%@", slot];
	NSString *onslotKey = [NSString stringWithFormat:@"onslot_%@", slot];
	NSString *maxKeypath = [NSString stringWithFormat:@"master_ship.maxeq_%@", slot];
	
	NSNumber *equipment = [self valueForKey:slotKey];
	NSNumber *current = [self valueForKey:onslotKey];
	NSNumber *max = [self valueForKeyPath:maxKeypath];
	
	if(max.integerValue == 0) return nil;
	
	if(equipment.integerValue == -1) return [NSString stringWithFormat:@"%@", max];
	
	if(self.equippedItem.count > slot.integerValue) {
		HMKCSlotItemObject *eq = self.equippedItem[slot.integerValue];
		if(![self.planeItemTypes containsObject:eq.master_slotItem.type_2]) return [NSString stringWithFormat:@"%@", max];
	}
	
	return [NSString stringWithFormat:@"%@/%@", current, max];
}

- (NSString *)planeString0
{
	return [self planeStringForSlot:@0];
}
- (NSString *)planeString1
{
	return [self planeStringForSlot:@1];
}
- (NSString *)planeString2
{
	return [self planeStringForSlot:@2];
}
- (NSString *)planeString3
{
	return [self planeStringForSlot:@3];
}
- (NSString *)planeString4
{
	return [self planeStringForSlot:@4];
}
- (NSString *)planeString5
{
	return [self planeStringForSlot:@5];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString0
{
	return [NSSet setWithObjects:@"onslot_0", @"master_ship.maxeq_0", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString1
{
	return [NSSet setWithObjects:@"onslot_1", @"master_ship.maxeq_1", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString2
{
	return [NSSet setWithObjects:@"onslot_2", @"master_ship.maxeq_2", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString3
{
	return [NSSet setWithObjects:@"onslot_3", @"master_ship.maxeq_3", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString4
{
	return [NSSet setWithObjects:@"onslot_4", @"master_ship.maxeq_4", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString5
{
	return [NSSet setWithObjects:@"onslot_5", @"master_ship.maxeq_5", @"equippedItem", nil];
}


- (NSColor *)planeStringColorForSlot:(NSNumber *)slot
{
	NSString *slotKey = [NSString stringWithFormat:@"slot_%@", slot];
	NSString *maxKeypath = [NSString stringWithFormat:@"master_ship.maxeq_%@", slot];
	
	NSNumber *equipment = [self valueForKey:slotKey];
	NSNumber *max = [self valueForKeyPath:maxKeypath];
	
	if(max.integerValue == 0) return [NSColor controlTextColor];
	
	if(equipment.integerValue == -1) return [NSColor disabledControlTextColor];
	
	if(self.equippedItem.count > slot.integerValue) {
		HMKCSlotItemObject *eq = self.equippedItem[slot.integerValue];
		if(![self.planeItemTypes containsObject:eq.master_slotItem.type_2]) return [NSColor disabledControlTextColor];;
	}
	
	return [NSColor controlTextColor];
}
- (NSColor *)planeString0Color
{
	return [self planeStringColorForSlot:@0];
}
- (NSColor *)planeString1Color
{
	return [self planeStringColorForSlot:@1];
}
- (NSColor *)planeString2Color
{
	return [self planeStringColorForSlot:@2];
}
- (NSColor *)planeString3Color
{
	return [self planeStringColorForSlot:@3];
}
- (NSColor *)planeString4Color
{
	return [self planeStringColorForSlot:@4];
}
- (NSColor *)planeString5Color
{
	return [self planeStringColorForSlot:@5];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString0Color
{
	return [NSSet setWithObjects:@"onslot_0", @"master_ship.maxeq_0", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString1Color
{
	return [NSSet setWithObjects:@"onslot_1", @"master_ship.maxeq_1", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString2Color
{
	return [NSSet setWithObjects:@"onslot_2", @"master_ship.maxeq_2", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString3Color
{
	return [NSSet setWithObjects:@"onslot_3", @"master_ship.maxeq_3", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString4Color
{
	return [NSSet setWithObjects:@"onslot_4", @"master_ship.maxeq_4", @"equippedItem", nil];
}
+ (NSSet *)keyPathsForValuesAffectingPlaneString5Color
{
	return [NSSet setWithObjects:@"onslot_5", @"master_ship.maxeq_5", @"equippedItem", nil];
}

@end
