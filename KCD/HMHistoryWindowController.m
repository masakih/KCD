//
//  HMHistoryWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMHistoryWindowController.h"

#import "HMLocalDataStore.h"

typedef NS_ENUM(NSUInteger, HMHistoryWindowTabIndex) {
	kKaihatuHistoryIndex = 0,
	kKenzoHistoryIndex = 1,
	kDropHistoryIndex = 2,
};

@interface HMHistoryWindowController () <NSTabViewDelegate>

@property (weak, nonatomic) IBOutlet NSSearchField *searchField;

@end

@implementation HMHistoryWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	
	return self;
}

- (void)awakeFromNib
{
	NSString *predicateFormat = @"";
	NSArrayController *target = nil;
	switch (self.selectedTabIndex) {
		case kKaihatuHistoryIndex:
			target = self.kaihatuHistoryController;
			predicateFormat = @"name contains $value";
			break;
		case kKenzoHistoryIndex:
			target = self.kenzoHistoryController;
			predicateFormat = @"name contains $value";
			break;
		case kDropHistoryIndex:
			target = self.dropHistoryController;
			predicateFormat = @"shipName contains $value";
			break;
			
	}
	
	if(!target) return;
	
	[self.searchField bind:NSPredicateBinding
				  toObject:target
			   withKeyPath:NSFilterPredicateBinding
				   options:@{
							 NSPredicateFormatBindingOption : predicateFormat,
							 }];
}

- (NSManagedObjectContext *)manageObjectContext
{
	return [[HMLocalDataStore defaultManager] managedObjectContext];
}

- (IBAction)delete:(id)sender
{
	NSArrayController *target = nil;
	switch (self.selectedTabIndex) {
		case kKaihatuHistoryIndex:
			target = self.kaihatuHistoryController;
			break;
		case kKenzoHistoryIndex:
			target = self.kenzoHistoryController;
			break;
		case kDropHistoryIndex:
			target = self.dropHistoryController;
			break;
			
	}
	
	if(!target) return;
	
	NSArray *original = [target selectedObjects];
	NSMutableArray *objectIds = [NSMutableArray new];
	for(NSManagedObject *object in original) {
		[objectIds addObject:object.objectID];
	}
	
	HMLocalDataStore *store = [HMLocalDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	for(NSManagedObjectID *objectID in objectIds) {
		NSManagedObject *object = [moc objectWithID:objectID];
		[moc deleteObject:object];
	}
}

#pragma mark - NSTabViewDelegate
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
	[self.searchField unbind:NSPredicateBinding];
	
	NSString *predicateFormat = @"";
	NSArrayController *target = nil;
	switch (self.selectedTabIndex) {
		case kKaihatuHistoryIndex:
			target = self.kaihatuHistoryController;
			predicateFormat = @"name contains $value";
			break;
		case kKenzoHistoryIndex:
			target = self.kenzoHistoryController;
			predicateFormat = @"name contains $value";
			break;
		case kDropHistoryIndex:
			target = self.dropHistoryController;
			predicateFormat = @"shipName contains $value";
			break;
			
	}
	
	if(!target) return;
	
	[self.searchField bind:NSPredicateBinding
				 toObject:target
			  withKeyPath:NSFilterPredicateBinding
				  options:@{
							NSPredicateFormatBindingOption : predicateFormat,
							}];
}


@end
