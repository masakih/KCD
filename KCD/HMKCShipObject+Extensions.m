//
//  HMKCShipObject+Extensions.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCShipObject+Extensions.h"

#import "HMServerDataStore.h"
#import "HMUserDefaults.h"


static NSArray *shortSTypeNames = nil;
static NSArray *levelUpExps = nil;

static NSMutableDictionary *names = nil;


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
		
		names = [NSMutableDictionary new];
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
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.houg_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"karyoku_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_0"] integerValue];
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
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.raig_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"raisou_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_1"] integerValue];
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
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.tyku_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"taiku_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_2"] integerValue];
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
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.souk_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"soukou_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_3"] integerValue];
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
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.luck_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"lucky_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_4"] integerValue];
	[self didAccessValueForKey:@"kyouka_4"];
	[self didAccessValueForKey:@"lucky_1"];
	[self didAccessValueForKey:@"master_ship"];
	
	return @(defaultValue + growth >= maxValue);
}

- (NSString *)name
{
	NSNumber *shipId = self.ship_id;
	if(!shipId || [shipId isKindOfClass:[NSNull class]]) return nil;
	
	@synchronized(names) {
		NSString *name = names[shipId];
		if(name) return name;
	}
	
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"MasterShip"
											error:&error
								  predicateFormat:@"id = %@", shipId];
	if([array count] == 0) {
		NSLog(@"MasterShip is invalid.");
		return nil;
	}
	
	NSString *name = [[array[0] valueForKey:@"name"] copy];
	@synchronized(names) {
		names[shipId] = name;
	}
	
	return name;
}
- (NSString *)shortTypeName
{
	[self willAccessValueForKey:@"master_ship"];
	NSNumber *idValue = [self valueForKeyPath:@"master_ship.stype.id"];
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
	NSInteger maxhp = [[self valueForKey:@"maxhp"] integerValue];
	CGFloat nowhp = [[self valueForKey:@"nowhp"] integerValue];
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
	
	NSInteger planType = [[self valueForKey:@"sally_area"] integerValue];
	if(planType == 1) return [NSColor colorWithCalibratedRed:0.000 green:0.043 blue:0.518 alpha:1.000];
	if(planType == 2) return [NSColor colorWithCalibratedRed:0.800 green:0.223 blue:0.000 alpha:1.000];
	return [NSColor controlTextColor];
}


- (NSNumber *)maxFuel
{
	return [self.master_ship valueForKey:@"fuel_max"];
}
- (NSNumber *)maxBull
{
	return [self.master_ship valueForKey:@"bull_max"];
}
@end
