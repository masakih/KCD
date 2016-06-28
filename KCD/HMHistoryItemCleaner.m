//
//  HMHistoryItemCleaner.m
//  KCD
//
//  Created by Hori,Masaki on 2016/06/27.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMHistoryItemCleaner.h"

#import "HMUserDefaults.h"

#import "HMLocalDataStore.h"


@implementation HMHistoryItemCleaner

- (void)cleanOldHistoryItems
{
	if(!HMStandardDefaults.cleanOldHistoryItems) return;
	
	HMLocalDataStore *store = [HMLocalDataStore oneTimeEditor];
	
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-1 * HMStandardDefaults.cleanSiceDays * 24 * 60 * 60];
	NSPredicate *p01 = [NSPredicate predicateWithFormat:@"date < %@", date];
	NSPredicate *p02 = [NSPredicate predicateWithFormat:@"mark = 0 || mark = nil"];
	NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p01, p02]];
	
	NSError *error = nil;
	NSArray<NSManagedObject *> *array = [store objectsWithEntityName:@"KaihatuHistory"
																  predicate:predicate
																	  error:&error];
	if(!error) {
		for(NSManagedObject *obj in array) {
			[store.managedObjectContext deleteObject:obj];
		}
	} else {
		NSLog(@"%s ERROR: KaihatuHistory, %@", __PRETTY_FUNCTION__, error);
	}
	
	error = nil;
	array = [store objectsWithEntityName:@"KenzoHistory"
							   predicate:predicate
								   error:&error];
	if(!error) {
		for(NSManagedObject *obj in array) {
			[store.managedObjectContext deleteObject:obj];
		}
	} else {
		NSLog(@"%s ERROR: KenzoHistory, %@", __PRETTY_FUNCTION__, error);
	}
	
	NSArray *area = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
	NSPredicate *p03 = [NSPredicate predicateWithFormat:@"mapArea IN %@", area];
	predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, p03]];
	
	error = nil;
	array = [store objectsWithEntityName:@"DropShipHistory"
							   predicate:predicate
								   error:&error];
	if(!error) {
		for(NSManagedObject *obj in array) {
			[store.managedObjectContext deleteObject:obj];
		}
	} else {
		NSLog(@"%s ERROR: DropShipHistory, %@", __PRETTY_FUNCTION__, error);
	}
}
@end
