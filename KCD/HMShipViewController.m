//
//  HMShipViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/04.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMShipViewController.h"

#import "HMCoreDataManager.h"


typedef NS_ENUM(NSInteger, ViewType) {
	kExpView = 0,
	kPowerView = 1,
	kPower2View = 2,
};

@interface HMShipViewController ()
@property (weak) NSView *currentTableView;
@end

@implementation HMShipViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (void)awakeFromNib
{
	self.currentTableView = self.expTableView;
}
- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

- (void)showViewWithNumber:(ViewType)number
{
	NSView *newSelection = nil;
	switch (number) {
		case kExpView:
			newSelection = self.expTableView;
			break;
		case kPowerView:
			newSelection = self.powerTableView;
			break;
		case kPower2View:
			newSelection = self.power2TableView;
			break;
	}
	
	if(!newSelection) return;
	if([self.currentTableView isEqual:newSelection]) return;
	
	[newSelection setFrame:[self.currentTableView frame]];
	[newSelection setAutoresizingMask:[self.currentTableView autoresizingMask]];
	[self.view replaceSubview:self.currentTableView with:newSelection];
	self.currentTableView = newSelection;
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
	[self.shipController setFetchPredicate:predicate];
	[self.shipController rearrangeObjects];
}

- (IBAction)changeView:(id)sender
{
	NSInteger tag = -1;
	if([sender respondsToSelector:@selector(selectedSegment)]) {
		NSSegmentedCell *cell = [sender cell];
		NSUInteger index = [sender selectedSegment];
		tag = [cell tagForSegment:index];
	} else {
		tag = [sender tag];
	}
	[self showViewWithNumber:tag];
}

@end
