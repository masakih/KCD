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
@dynamic primitiveBull;
@dynamic primitiveCond;
@dynamic primitiveExp;
@dynamic primitiveFuel;
@dynamic primitiveId;
@dynamic primitiveKaihi_0;
@dynamic primitiveKaihi_1;
@dynamic primitiveKaryoku_0;
@dynamic primitiveKaryoku_1;
@dynamic primitiveKyouka_0;
@dynamic primitiveKyouka_1;
@dynamic primitiveKyouka_2;
@dynamic primitiveKyouka_3;
@dynamic primitiveKyouka_4;
@dynamic primitiveLocked;
@dynamic primitiveLucky_0;
@dynamic primitiveLucky_1;
@dynamic primitiveLv;
@dynamic primitiveMaxhp;
@dynamic primitiveNdock_time;
@dynamic primitiveNowhp;
@dynamic primitiveOnslot_0;
@dynamic primitiveOnslot_1;
@dynamic primitiveOnslot_2;
@dynamic primitiveOnslot_3;
@dynamic primitiveOnslot_4;
@dynamic primitiveRaisou_0;
@dynamic primitiveRaisou_1;
@dynamic primitiveSakuteki_0;
@dynamic primitiveSakuteki_1;
@dynamic primitiveShip_id;
@dynamic primitiveSlot_0;
@dynamic primitiveSlot_1;
@dynamic primitiveSlot_2;
@dynamic primitiveSlot_3;
@dynamic primitiveSlot_4;
@dynamic primitiveSortno;
@dynamic primitiveSoukou_0;
@dynamic primitiveSoukou_1;
@dynamic primitiveSrate;
@dynamic primitiveTaiku_0;
@dynamic primitiveTaiku_1;
@dynamic primitiveTaisen_0;
@dynamic primitiveTaisen_1;
@dynamic primitiveUse_bull;
@dynamic primitiveUse_fuel;

@dynamic primitiveMaster_ship;


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

#if 0
- (void)setBull:(NSNumber *)bull
{
	if([self.primitiveBull isEqual:bull]) return;
	
	self.primitiveBull = bull;
}
- (void)setCond:(NSNumber *)cond
{
	if([self.primitiveCond isEqual:cond]) return;
	
	self.primitiveCond = cond;
}
- (void)setExp:(NSNumber *)exp
{
	if([self.primitiveExp isEqual:exp]) return;
	
	self.primitiveExp = exp;
}
- (void)setFuel:(NSNumber *)fuel
{
	if([self.primitiveFuel isEqual:fuel]) return;
	
	self.primitiveFuel = fuel;
}
- (void)setId:(NSNumber *)id
{
	if([self.primitiveId isEqual:id]) return;
	
	self.primitiveId = id;
}
- (void)setKaihi_0:(NSNumber *)kaihi_0
{
	if([self.primitiveKaihi_0 isEqual:kaihi_0]) return;
	
	self.primitiveKaihi_0 = kaihi_0;
}
- (void)setKaihi_1:(NSNumber *)kaihi_1
{
	if([self.primitiveKaihi_1 isEqual:kaihi_1]) return;
	
	self.primitiveKaihi_1 = kaihi_1;
}
- (void)setKaryoku_0:(NSNumber *)karyoku_0
{
	if([self.primitiveKaryoku_0 isEqual:karyoku_0]) return;
	
	self.primitiveKaryoku_0 = karyoku_0;
}
- (void)setKaryoku_1:(NSNumber *)karyoku_1
{
	if([self.primitiveKaryoku_1 isEqual:karyoku_1]) return;
	
	self.primitiveKaryoku_1 = karyoku_1;
}
- (void)setLocked:(NSNumber *)locked
{
	if([self.primitiveLocked isEqual:locked]) return;
	
	self.primitiveLocked = locked;
}
- (void)setLucky_0:(NSNumber *)lucky_0
{
	if([self.primitiveLucky_0 isEqual:lucky_0]) return;
	
	self.primitiveLucky_0 = lucky_0;
}
- (void)setLucky_1:(NSNumber *)lucky_1
{
	if([self.primitiveLucky_1 isEqual:lucky_1]) return;
	
	self.primitiveLucky_1 = lucky_1;
}
- (void)setLv:(NSNumber *)lv
{
	if([self.primitiveLv isEqual:lv]) return;
	
	self.primitiveLv = lv;
}
- (void)setMaxhp:(NSNumber *)maxhp
{
	if([self.primitiveMaxhp isEqual:maxhp]) return;
	
	self.primitiveMaxhp = maxhp;
}
- (void)setNdock_time:(NSNumber *)ndock_time
{
	if([self.primitiveNdock_time isEqual:ndock_time]) return;
	
	self.primitiveNdock_time = ndock_time;
}
- (void)setNowhp:(NSNumber *)nowhp
{
	if([self.primitiveNowhp isEqual:nowhp]) return;
	
	self.primitiveNowhp = nowhp;
}
- (void)setOnslot_0:(NSNumber *)onslot_0
{
	if([self.primitiveOnslot_0 isEqual:onslot_0]) return;
	
	self.primitiveOnslot_0 = onslot_0;
}
- (void)setOnslot_1:(NSNumber *)onslot_1
{
	if([self.primitiveOnslot_1 isEqual:onslot_1]) return;
	
	self.primitiveOnslot_1 = onslot_1;
}
- (void)setOnslot_2:(NSNumber *)onslot_2
{
	if([self.primitiveOnslot_2 isEqual:onslot_2]) return;
	
	self.primitiveOnslot_2 = onslot_2;
}
- (void)setOnslot_3:(NSNumber *)onslot_3
{
	if([self.primitiveOnslot_3 isEqual:onslot_3]) return;
	
	self.primitiveOnslot_3 = onslot_3;
}
- (void)setOnslot_4:(NSNumber *)onslot_4
{
	if([self.primitiveOnslot_4 isEqual:onslot_4]) return;
	
	self.primitiveOnslot_4 = onslot_4;
}
- (void)setRaisou_0:(NSNumber *)raisou_0
{
	if([self.primitiveRaisou_0 isEqual:raisou_0]) return;
	
	self.primitiveRaisou_0 = raisou_0;
}
- (void)setRaisou_1:(NSNumber *)raisou_1
{
	if([self.primitiveRaisou_1 isEqual:raisou_1]) return;
	
	self.primitiveRaisou_1 = raisou_1;
}
- (void)setSakuteki_0:(NSNumber *)sakuteki_0
{
	if([self.primitiveSakuteki_0 isEqual:sakuteki_0]) return;
	
	self.primitiveSakuteki_0 = sakuteki_0;
}
- (void)setSakuteki_1:(NSNumber *)sakuteki_1
{
	if([self.primitiveSakuteki_1 isEqual:sakuteki_1]) return;
	
	self.primitiveSakuteki_1 = sakuteki_1;
}
- (void)setShip_id:(NSNumber *)ship_id
{
	if([self.primitiveShip_id isEqual:ship_id]) return;
	
	self.primitiveShip_id = ship_id;
}
- (void)setSlot_0:(NSNumber *)slot_0
{
	if([self.primitiveSlot_0 isEqual:slot_0]) return;
	
	self.primitiveSlot_0 = slot_0;
}
- (void)setSlot_1:(NSNumber *)slot_1
{
	if([self.primitiveSlot_1 isEqual:slot_1]) return;
	
	self.primitiveSlot_1 = slot_1;
}
- (void)setSlot_2:(NSNumber *)slot_2
{
	if([self.primitiveSlot_2 isEqual:slot_2]) return;
	
	self.primitiveSlot_2 = slot_2;
}
- (void)setSlot_3:(NSNumber *)slot_3
{
	if([self.primitiveSlot_3 isEqual:slot_3]) return;
	
	self.primitiveSlot_3 = slot_3;
}
- (void)setSlot_4:(NSNumber *)slot_4
{
	if([self.primitiveSlot_4 isEqual:slot_4]) return;
	
	self.primitiveSlot_4 = slot_4;
}
- (void)setSortno:(NSNumber *)sortno
{
	if([self.primitiveSortno isEqual:sortno]) return;
	
	self.primitiveSortno = sortno;
}
- (void)setSoukou_0:(NSNumber *)soukou_0
{
	if([self.primitiveSoukou_0 isEqual:soukou_0]) return;
	
	self.primitiveSoukou_0 = soukou_0;
}
- (void)setSoukou_1:(NSNumber *)soukou_1
{
	if([self.primitiveSoukou_1 isEqual:soukou_1]) return;
	
	self.primitiveSoukou_1 = soukou_1;
}
- (void)setSrate:(NSNumber *)srate
{
	if([self.primitiveSrate isEqual:srate]) return;
	
	self.primitiveSrate = srate;
}
- (void)setTaiku_0:(NSNumber *)taiku_0
{
	if([self.primitiveTaiku_0 isEqual:taiku_0]) return;
	
	self.primitiveTaiku_0 = taiku_0;
}
- (void)setTaiku_1:(NSNumber *)taiku_1
{
	if([self.primitiveTaiku_1 isEqual:taiku_1]) return;
	
	self.primitiveTaiku_1 = taiku_1;
}
- (void)setTaisen_0:(NSNumber *)taisen_0
{
	if([self.primitiveTaisen_0 isEqual:taisen_0]) return;
	
	self.primitiveTaisen_0 = taisen_0;
}
- (void)setTaisen_1:(NSNumber *)taisen_1
{
	if([self.primitiveTaisen_1 isEqual:taisen_1]) return;
	
	self.primitiveTaisen_1 = taisen_1;
}
- (void)setUse_bull:(NSNumber *)use_bull
{
	if([self.primitiveUse_bull isEqual:use_bull]) return;
	
	self.primitiveUse_bull = use_bull;
}
- (void)setUse_fuel:(NSNumber *)use_fuel
{
	if([self.primitiveUse_fuel isEqual:use_fuel]) return;
	
	self.primitiveUse_fuel = use_fuel;
}
#endif

- (void)setMaster_ship:(id)value
{
	if([self.primitiveMaster_ship isEqual:value]) return;
	
	//	NSLog(@"Ship did change master_ship.");
	[self willChangeValueForKey:@"master_ship"];
	self.primitiveMaster_ship = value;
	[self didChangeValueForKey:@"master_ship"];
}
- (NSManagedObject *)master_ship
{
	return self.primitiveMaster_ship;
}

- (NSNumber *)master_sortno
{
	return nil;
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
#if 1
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
#endif
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
@end
