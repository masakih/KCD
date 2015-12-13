//
//  HMUpgradableShipsWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/26.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMUpgradableShipsWindowController.h"

#import "HMAppDelegate.h"
#import "HMServerDataStore.h"
#import "HMUserDefaults.h"
#import "HMKCShipObject+Extensions.h"


static NSArray *sExcludeShiIDs = nil;

@interface HMUpgradableShipsWindowController ()

@property (nonatomic, weak) IBOutlet NSMenu *contextualMenu;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSArrayController *shipsController;

@property (nonatomic, strong) NSArray *excludeShiIDs;
@end


BOOL isExcludeShipID(id shipID)
{
	if([sExcludeShiIDs containsObject:shipID]) {
		return YES;
	}
	return NO;
}

@implementation HMUpgradableShipsWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		[self loadExcludeShipIDs];
	}
	return self;
}

- (NSURL *)excludeAhipIDsSaveURL
{
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	NSURL *dir = appDelegate.supportDirectory;
	NSURL *pathURL = [dir URLByAppendingPathComponent:@"ExcludeShipIDs"];
	return pathURL;
}
- (void)saveExcludeShipIDs
{
	NSURL *pathURL = [self excludeAhipIDsSaveURL];
	
	[self.excludeShiIDs writeToURL:pathURL atomically:YES];
}
- (void)loadExcludeShipIDs
{
	NSURL *pathURL = [self excludeAhipIDsSaveURL];
	NSArray *array = [NSArray arrayWithContentsOfURL:pathURL];
	if(array && ![array isKindOfClass:[NSArray class]]) {
		NSLog(@"%@ is broken.", pathURL.path);
		array = nil;
	}
	self.excludeShiIDs = array ?: [NSArray array];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (NSArray *)excludeShiIDs
{
	return sExcludeShiIDs;
}
- (void)setExcludeShiIDs:(NSArray *)excludeShiIDs
{
	sExcludeShiIDs = excludeShiIDs;
	[self saveExcludeShipIDs];
}

+ (NSSet *)keyPathsForValuesAffectingFilterPredicate
{
	return [NSSet setWithObjects:@"showLevelOneShipInUpgradableList", @"excludeShiIDs", @"showsExcludedShipInUpgradableList", nil];
}
- (void)setShowLevelOneShipInUpgradableList:(BOOL)showLevelOneShipInUpgradableList
{
	HMStandardDefaults.showLevelOneShipInUpgradableList = showLevelOneShipInUpgradableList;
}
- (BOOL)showLevelOneShipInUpgradableList
{
	return HMStandardDefaults.showLevelOneShipInUpgradableList;
}
- (void)setShowsExcludedShipInUpgradableList:(BOOL)showsExcludedShipInUpgradableList
{
	HMStandardDefaults.showsExcludedShipInUpgradableList = showsExcludedShipInUpgradableList;
}
- (BOOL)showsExcludedShipInUpgradableList
{
	return HMStandardDefaults.showsExcludedShipInUpgradableList;
}
- (NSPredicate *)filterPredicate
{
	NSPredicate *filterPredicate = nil;
	NSPredicate *excludeShip = nil;
	if(!HMStandardDefaults.showLevelOneShipInUpgradableList) {
		filterPredicate = [NSPredicate predicateWithFormat:@"lv != 1"];
	}
	if(!self.showsExcludedShipInUpgradableList && self.excludeShiIDs.count != 0) {
		excludeShip = [NSPredicate predicateWithFormat:@"NOT id IN %@", self.excludeShiIDs];
	}
	if(filterPredicate && excludeShip) {
		return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType
										   subpredicates:@[filterPredicate, excludeShip]];
	}
	if(filterPredicate) {
		return filterPredicate;
	}
	if(excludeShip ) {
		return excludeShip;
	}
	return nil;
}

- (void)includeShip:(id)shipID
{
	NSMutableArray *array = [self.excludeShiIDs mutableCopy];
	[array removeObject:shipID];
	self.excludeShiIDs = array;
}
- (void)excludeShip:(id)shipID
{
	NSMutableArray *array = [self.excludeShiIDs mutableCopy];
	[array addObject:shipID];
	self.excludeShiIDs = array;
}
- (IBAction)showHideShip:(id)sender
{
	NSInteger row = self.tableView.clickedRow;
	if(row == -1) return;
	
	HMKCShipObject *ship = [[self.shipsController arrangedObjects] objectAtIndex:row];
	id shipID = ship.id;
	if([self.excludeShiIDs containsObject:shipID]) {
		[self includeShip:shipID];
	} else {
		[self excludeShip:shipID];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = menuItem.action;
	if(action == @selector(showHideShip:)) {
		NSInteger row = self.tableView.clickedRow;
		if(row == -1) return NO;
		
		HMKCShipObject *ship = [[self.shipsController arrangedObjects] objectAtIndex:row];
		id shipID = ship.id;
		if([self.excludeShiIDs containsObject:shipID]) {
			menuItem.title = @"Show";
		} else {
			menuItem.title = @"Hide";
		}
		return YES;
	}
	
	return NO;
}

@end
