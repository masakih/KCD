//
//  HMKCShipObject.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCShipObject.h"

static NSArray *shortSTypeNames = nil;
static NSArray *levelUpExps = nil;

@implementation HMKCShipObject
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

- (NSNumber *)master_sortno
{
	return nil;
}

- (NSNumber *)isMaxKaryoku
{
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.houg_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"karyoku_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_0"] integerValue];
	
	return @(defaultValue + growth >= maxValue);
}
- (NSNumber *)isMaxRaisou
{
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.raig_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"raisou_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_1"] integerValue];
	
	return @(defaultValue + growth >= maxValue);
}
- (NSNumber *)isMaxTaiku
{
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.tyku_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"taiku_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_2"] integerValue];
	
	return @(defaultValue + growth >= maxValue);
}
- (NSNumber *)isMaxSoukou
{
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.souk_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"soukou_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_3"] integerValue];
	
	return @(defaultValue + growth >= maxValue);
}
- (NSNumber *)isMaxLucky
{
	NSInteger defaultValue = [[self valueForKeyPath:@"master_ship.luck_0"] integerValue];
	NSInteger maxValue = [[self valueForKey:@"lucky_1"] integerValue];
	NSInteger growth = [[self valueForKey:@"kyouka_4"] integerValue];
	
	return @(defaultValue + growth >= maxValue);
}

- (NSString *)shortTypeName
{
	NSNumber *idValue = [self valueForKeyPath:@"master_ship.stype.id"];
	if(!idValue || [idValue isKindOfClass:[NSNull class]]) return nil;
	
	if([shortSTypeNames count] < [idValue integerValue]) return nil;
	
	return shortSTypeNames[[idValue integerValue] - 1];
}

- (NSNumber *)next
{
	NSUInteger nextExp = [[levelUpExps objectAtIndex:[[self valueForKey:@"lv"] integerValue]] integerValue];
	
	return [NSNumber numberWithInteger:nextExp - [[self valueForKey:@"exp"] integerValue]];
}

- (NSColor *)statusColor
{
#if 0
	NSInteger maxhp = [[self valueForKey:@"maxhp"] integerValue];
	CGFloat nowhp = [[self valueForKey:@"nowhp"] integerValue];
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

@end
