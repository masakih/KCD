//
//  HMPowerUpSupportViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/06.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMPowerUpSupportViewController.h"

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"
#import "HMServerDataStore.h"


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
	
	[self.shipController fetchWithRequest:nil merge:YES error:NULL];
	[self.shipController setSortDescriptors:HMStandardDefaults.powerupSupportSortDecriptors];
	[self.shipController addObserver:self
							  forKeyPath:NSSortDescriptorsBinding
								 options:0
								 context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:NSSortDescriptorsBinding]) {
		HMStandardDefaults.powerupSupportSortDecriptors = [self.shipController sortDescriptors];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

//- (id)valueForUndefinedKey:(NSString *)key
//{
//	NSArray *defindeKyes = @[@"hideMaxKaryoku", @"hideMaxRaisou", @"hideMaxTaiku", @"hideMaxSoukou", @"hideMaxLucky"];
//	if([defindeKyes containsObject:key]) {
//		return [HMStandardDefaults valueForKey:key];
//	}
//	
//	return [super valueForUndefinedKey:key];
//}
- (BOOL)hideMaxKaryoku
{
	return HMStandardDefaults.hideMaxKaryoku;
}
- (BOOL)hideMaxRaisou
{
	return HMStandardDefaults.hideMaxRaisou;
}
- (BOOL)hideMaxTaiku
{
	return HMStandardDefaults.hideMaxTaiku;
}
- (BOOL)hideMaxSoukou
{
	return HMStandardDefaults.hideMaxSoukou;
}
- (BOOL)hideMaxLucky
{
	return HMStandardDefaults.hideMaxLucky;
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
	NSArray *categories = [[NSApp delegate] shipTypeCategories];
	
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
