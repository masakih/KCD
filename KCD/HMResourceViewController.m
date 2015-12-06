//
//  HMResourceViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/12/06.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMResourceViewController.h"

#import "HMUserDefaults.h"

#import "HMServerDataStore.h"

@interface HMResourceViewController ()
@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet NSArrayController *shipController;
@property (nonatomic, strong) IBOutlet NSObjectController *basicController;
@property (nonatomic, strong) NSNumber *maxChara;
@property (nonatomic, strong) NSNumber *shipCount;
@property (readonly) NSColor *shipNumberColor;
@property NSInteger minimumColoredShipCount;
@end

@implementation HMResourceViewController

- (void)awakeFromNib
{
	[self bind:@"maxChara" toObject:self.basicController withKeyPath:@"selection.max_chara" options:nil];
	[self bind:@"shipCount" toObject:self.shipController withKeyPath:@"arrangedObjects.@count" options:nil];
}

+ (NSSet *)keyPathsForValuesAffectingShipNumberColor
{
	return [NSSet setWithObjects:@"maxChara", @"shipCount", @"minimumColoredShipCount", nil];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (NSColor *)shipNumberColor
{
	NSInteger max = self.maxChara.integerValue;
	NSInteger current = self.shipCount.integerValue;
	
	if(current > max - self.minimumColoredShipCount) {
		return [NSColor orangeColor];
	}
	
	return [NSColor controlTextColor];
}
- (void)setMinimumColoredShipCount:(NSInteger)minimumColoredShipCount
{
	HMStandardDefaults.minimumColoredShipCount = minimumColoredShipCount;
}
- (NSInteger)minimumColoredShipCount
{
	return HMStandardDefaults.minimumColoredShipCount;
}
@end
