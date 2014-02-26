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
- (NSNumber *)master_sortno
{
	return nil;
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

@end
