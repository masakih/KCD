//
//  HMPowerUpSupportViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/06.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPowerUpSupportViewController.h"

#import "HMCoreDataManager.h"


@interface HMPowerUpSupportViewController ()

@end

@implementation HMPowerUpSupportViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}
- (void)awakeFromNib
{
	[self changeCategory:nil];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

- (id)valueForUndefinedKey:(NSString *)key
{
	NSArray *defindeKyes = @[@"hideMaxKaryoku", @"hideMaxRaisou", @"hideMaxTaiku", @"hideMaxSoukou", @"hideMaxLucky"];
	if([defindeKyes containsObject:key]) {
		return [[NSUserDefaults standardUserDefaults] objectForKey:key];
	}
	
	return [super valueForUndefinedKey:key];
}
- (BOOL)hideMaxKaryoku
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxKaryoku"];
}
- (BOOL)hideMaxRaisou
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxRaisou"];
}
- (BOOL)hideMaxTaiku
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxTaiku"];
}
- (BOOL)hideMaxSoukou
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxSoukou"];
}
- (BOOL)hideMaxLucky
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMaxLucky"];
}

- (NSPredicate *)omitPredicate
{
	NSMutableArray *hideKeys = [NSMutableArray array];
	if(self.hideMaxKaryoku) {
		[hideKeys addObject:@"isMaxKaryoku != TRUE"];
	}
	if(self.hideMaxRaisou) {
		[hideKeys addObject:@"isMaxRaisou != TRUE"];
	}
	if(self.hideMaxTaiku) {
		[hideKeys addObject:@"isMaxTaiku != TRUE"];
	}
	if(self.hideMaxSoukou) {
		[hideKeys addObject:@"isMaxSoukou != TRUE"];
	}
	if(self.hideMaxLucky) {
		[hideKeys addObject:@"isMaxLucky != TRUE"];
	}
	
	if([hideKeys count] == 0) return nil;
	
	NSString *predicateString = [hideKeys componentsJoinedByString:@" AND "];
	
	return [NSPredicate predicateWithFormat:predicateString];
}

- (IBAction)changeCategory:(id)sender
{
	NSArray *categories = @[
							@[@2],
							@[@3, @4],
							@[@5,@6],
							@[@7, @11, @16, @18],
							@[@8, @9, @10, @12],
							@[@13, @14],
							@[@1, @15, @17]
							];
	
	NSPredicate *predicate = [self omitPredicate];
	NSUInteger tag = [self.typeSegment selectedSegment];
	if(tag != 0 && tag < 8) {
		NSPredicate *catPredicate = [NSPredicate predicateWithFormat:@"master_ship.stype.id  in %@", categories[tag - 1]];
		if(predicate) {
			NSArray *sub = @[predicate, catPredicate];
			predicate = [NSCompoundPredicate andPredicateWithSubpredicates:sub];
		} else {
			predicate = catPredicate;
		}
	}
	[self.shipController setFilterPredicate:predicate];
	[self.shipController rearrangeObjects];
}

@end
