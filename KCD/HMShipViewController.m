//
//  HMShipViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/04.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMShipViewController.h"

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"
#import "HMServerDataStore.h"


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
	
	
	[self.shipController fetchWithRequest:nil merge:YES error:NULL];
	[self.shipController setSortDescriptors:HMStandardDefaults.shipviewSortDescriptors];
	[self.shipController addObserver:self
						  forKeyPath:NSSortDescriptorsBinding
							 options:0
							 context:NULL];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(scrollViewDidEndLiveScrollNotification:)
			   name:NSScrollViewDidEndLiveScrollNotification
			 object:self.expTableView];
	[nc addObserver:self
		   selector:@selector(scrollViewDidEndLiveScrollNotification:)
			   name:NSScrollViewDidEndLiveScrollNotification
			 object:self.powerTableView];
	[nc addObserver:self
		   selector:@selector(scrollViewDidEndLiveScrollNotification:)
			   name:NSScrollViewDidEndLiveScrollNotification
			 object:self.power2TableView];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:NSSortDescriptorsBinding]) {
		HMStandardDefaults.shipviewSortDescriptors = [self.shipController sortDescriptors];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
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
	NSUInteger tag = [sender selectedSegment];
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	NSPredicate *predicate = [appDelegate predicateForShipType:tag];
	[self.shipController setFilterPredicate:predicate];
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

#pragma mark - NSScrollViewDidEndLiveScrollNotification
- (void)scrollViewDidEndLiveScrollNotification:(NSNotification *)notification
{
	id object = [notification object];
	
	NSRect visibleRect = [object documentVisibleRect];
	
	for(id item in @[self.expTableView, self.powerTableView, self.power2TableView]) {
		if(![object isEqual:item]) {
			NSView *view = [item documentView];
			[view scrollRectToVisible:visibleRect];
		}
	}
}
@end
