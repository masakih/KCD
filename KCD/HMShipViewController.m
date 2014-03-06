//
//  HMShipViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/04.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMShipViewController.h"

#import "HMCoreDataManager.h"


@interface HMShipViewController ()

@end

@implementation HMShipViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}
- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
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
	
	NSPredicate *predicate = nil;
	NSUInteger tag = [sender selectedSegment];
	if(tag != 0 && tag < 8) {
		predicate = [NSPredicate predicateWithFormat:@"master_ship.stype.id  in %@", categories[tag - 1]];
	}
	[self.shipController setFilterPredicate:predicate];
}

@end
