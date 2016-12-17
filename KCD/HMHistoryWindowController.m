//
//  HMHistoryWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMHistoryWindowController.h"

#import "HMLocalDataStore.h"

#import "HMKaihatuHistory.h"
#import "HMKenzoHistory.h"
#import "HMDropShipHistory.h"


typedef NS_ENUM(NSUInteger, HMHistoryWindowTabIndex) {
	kKaihatuHistoryIndex = 0,
	kKenzoHistoryIndex = 1,
	kDropHistoryIndex = 2,
};

@interface HMHistoryWindowController () <NSTabViewDelegate, NSTableViewDelegate>

@property (readonly) NSManagedObjectContext *manageObjectContext;

@property NSInteger selectedTabIndex;

@property (nonatomic, strong) IBOutlet NSArrayController *kaihatuHistoryController;
@property (nonatomic, strong) IBOutlet NSArrayController *kenzoHistoryController;
@property (nonatomic, strong) IBOutlet NSArrayController *dropHistoryController;

@property (nonatomic, weak) IBOutlet NSTableView *kaihatuHistoryTableView;
@property (nonatomic, weak) IBOutlet NSTableView *kenzoHistoryTableView;
@property (nonatomic, weak) IBOutlet NSTableView *dropHistoryTableView;

@property (nonatomic, weak) IBOutlet NSSearchField *searchField;

@property (nonatomic, strong) IBOutlet NSTouchBar *myTouchBar;
@property (nonatomic, weak) IBOutlet NSButton *searchButton;

@end

@implementation HMHistoryWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
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
	
	for(NSManagedObjectID *objectID in objectIds) {
		NSManagedObject *object = [store objectWithID:objectID];
		[store deleteObject:object];
	}
}

- (IBAction)addMark:(id)sender
{
	NSArrayController *target = nil;
	NSTableView *targetView = nil;
	switch (self.selectedTabIndex) {
		case kKaihatuHistoryIndex:
			target = self.kaihatuHistoryController;
			targetView = self.kaihatuHistoryTableView;
			break;
		case kKenzoHistoryIndex:
			target = self.kenzoHistoryController;
			targetView = self.kenzoHistoryTableView;
			break;
		case kDropHistoryIndex:
			target = self.dropHistoryController;
			targetView = self.dropHistoryTableView;
			break;
			
	}
	
	if(!target) return;
	
	NSArray *a = target.arrangedObjects;
	id o = a[targetView.clickedRow];
	
	NSString *entityName = nil;
	NSPredicate *predicate = nil;
	switch (self.selectedTabIndex) {
		case kKaihatuHistoryIndex:
		{
			HMKaihatuHistory *obj = o;
			entityName = @"KaihatuHistory";
			predicate = [NSPredicate predicateWithFormat:@"date = %@ AND name = %@", obj.date, obj.name];
			break;
		}
		case kKenzoHistoryIndex:
		{
			HMKenzoHistory *obj = o;
			entityName = @"KenzoHistory";
			predicate = [NSPredicate predicateWithFormat:@"date = %@ AND name = %@", obj.date, obj.name];
			break;
		}
		case kDropHistoryIndex:
		{
			HMDropShipHistory *obj = o;
			entityName = @"DropShipHistory";
			predicate = [NSPredicate predicateWithFormat:@"date = %@ AND mapCell = %@", obj.date, obj.mapCell];
			break;
		}
			
	}
	
	HMLocalDataStore *store = [HMLocalDataStore oneTimeEditor];
	NSError *error = nil;
	NSArray<HMDropShipHistory *> *array = [store objectsWithEntityName:entityName predicate:predicate error:&error];
	if(array.count == 0) {
		NSLog(@"%s: ERROR", __PRETTY_FUNCTION__);
		return;
	}
	
	BOOL mark = array[0].mark.boolValue;
	array[0].mark = mark ? @NO : @YES;
	[store saveAction:nil];
}

- (IBAction)selectSearchField:(id)sender
{
    [self.window makeFirstResponder:self.searchField];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = menuItem.action;
	if(action == @selector(addMark:)) {
		NSArrayController *target = nil;
		NSTableView *targetView = nil;
		switch (self.selectedTabIndex) {
			case kKaihatuHistoryIndex:
				target = self.kaihatuHistoryController;
				targetView = self.kaihatuHistoryTableView;
				break;
			case kKenzoHistoryIndex:
				target = self.kenzoHistoryController;
				targetView = self.kenzoHistoryTableView;
				break;
			case kDropHistoryIndex:
				target = self.dropHistoryController;
				targetView = self.dropHistoryTableView;
				break;
				
		}
		
		if(target) {
			NSArray<HMDropShipHistory *> *a = target.arrangedObjects;
			HMDropShipHistory *o = a[targetView.clickedRow];
			
			if(o.mark.boolValue) {
				menuItem.title = NSLocalizedString(@"Remove mark", @"Remove history mark.");
			} else {
				menuItem.title = NSLocalizedString(@"Add mark", @"Add history mark.");
			}
		}
	}
	
	return YES;
}

- (NSTouchBar *)touchBar
{
    if(NSClassFromString(@"NSTouchBar") == Nil) return nil;
    
    if(self.myTouchBar) return self.myTouchBar;
    
    NSArray *toplevel = nil;
    NSBundle *mainBundle = [NSBundle mainBundle];
    [mainBundle loadNibNamed:@"HistoryWindowTouchBar"
                       owner:self
             topLevelObjects:&toplevel];
    
    return self.myTouchBar;
}

#pragma mark - NSTableViewDelegate & NSTableViewDataSource

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSView *itemView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
	return itemView;
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
