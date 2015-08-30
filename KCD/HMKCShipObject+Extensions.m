//
//  HMKCShipObject+Extensions.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterShipObject.h"

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

+ (NSSet *)keyPathsForValuesAffectingStatusColor
{
	return [NSSet setWithObjects:@"nowhp", @"maxph", nil];
}
+ (NSSet *)keyPathsForValuesAffectingConditionColor
{
	return [NSSet setWithObjects:@"cond", nil];
}
+ (NSSet *)keyPathsForValuesAffectingName
{
	return [NSSet setWithObjects:@"ship_id", nil];
}
+ (NSSet *)keyPathsForValuesAffectingShortTypeName
{
	return [NSSet setWithObjects:@"ship_id", nil];
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

- (NSString *)name
{
	return [self.master_ship valueForKey:@"name"];
}
- (NSString *)shortTypeName
{
	[self willAccessValueForKey:@"master_ship"];
	NSNumber *idValue = [self.master_ship.stype valueForKey:@"id"];
	[self didAccessValueForKey:@"master_ship"];
	if(!idValue || [idValue isKindOfClass:[NSNull class]]) return nil;
	
	if([shortSTypeNames count] < [idValue integerValue]) return nil;
	
	return shortSTypeNames[[idValue integerValue] - 1];
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
- (NSNumber *)seiku
{
	NSArray *effectiveTypes = @[@6, @7, @8, @11];
	__block NSInteger totalSeiku = 0;
	for(NSInteger i = 0; i < 5; i++) {
		HMKCSlotItemObject *slotItem = [self slotItemAtIndex:i];
		HMKCMasterSlotItemObject *master = slotItem.master_slotItem;
		NSNumber *type2 = master.type_2;
		if(![effectiveTypes containsObject:type2]) {
//			NSLog(@"Type %@ is not effective.", type2);
			continue;
		}
		
		NSString *key = [NSString stringWithFormat:@"onslot_%ld", i];
		NSNumber *itemCountValue = [self valueForKey:key];
		NSNumber *taikuValue = master.tyku;
		NSInteger itemCount = [itemCountValue integerValue];
		NSInteger taiku = [taikuValue integerValue];
		if(itemCount && taiku) {
			totalSeiku += floor(taiku * sqrt(itemCount));
//			NSLog(@"slot -> %ld, name -> %@, itemCount -> %ld, taiku -> %ld, total -> %ld", i, master.name, itemCount, taiku, totalSeiku);
		} else {
//			NSLog(@"itemCount -> %ld, taiku -> %ld", itemCount, taiku);
		}
	}
	
	return @(totalSeiku);
}
- (NSNumber *)extraSeiku
{
	NSArray *fighterTypes = @[@6];
	NSArray *bomberTypes = @[@7];
	NSArray *attackerTypes = @[@8];
	NSArray *floatplaneBomberTypes = @[@11];
	__block NSInteger extraSeiku = 0;
	for(NSInteger i = 0; i < 5; i++) {
		HMKCSlotItemObject *slotItem = [self slotItemAtIndex:i];
		NSNumber *airLevel = slotItem.alv;
		if(![airLevel isEqualToNumber:@(7)]) continue;
		
		NSString *key = [NSString stringWithFormat:@"onslot_%ld", i];
		NSNumber *itemCountValue = [self valueForKey:key];
		NSInteger itemCount = [itemCountValue integerValue];
		if(itemCount == 0) continue;
		
		HMKCMasterSlotItemObject *master = slotItem.master_slotItem;
		NSNumber *type2 = master.type_2;
		if([fighterTypes containsObject:type2]) {
			extraSeiku += 25;
		}
		if([bomberTypes containsObject:type2]) {
			extraSeiku += 3;
		}
		if([attackerTypes containsObject:type2]) {
			extraSeiku += 3;
		}
		if([floatplaneBomberTypes containsObject:type2]) {
			extraSeiku += 9;
		}
	}
	
	return @(extraSeiku);
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

@end
