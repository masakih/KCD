//
//  HMShipMasterDetailWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/12/14.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#ifdef DEBUG

#import "HMShipMasterDetailWindowController.h"

#import "HMAppDelegate.h"
#import "HMServerDataStore.h"
#import "HMFleetManager.h"
#import "HMKCShipObject+Extensions.h"


@interface HMShipMasterDetailWindowController ()

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet NSArrayController *shipController;
@property (nonatomic, strong) IBOutlet NSArrayController *fleetMemberController;

@property (nonatomic, weak) IBOutlet NSTableView *shipsView;
@property (nonatomic, weak) IBOutlet NSTableView *fleetMemberView;


@property (nonatomic, strong) HMKCShipObject *selectedShip;
@property (strong) NSArray *spec;

@property (strong) NSArray *equipments;

@property (nonatomic, strong) HMFleetManager *fleetManager;

@end

@implementation HMShipMasterDetailWindowController

- (instancetype)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		HMAppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
		_fleetManager = appDelegate.fleetManager;
	}
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (void)setSelectedShip:(HMKCShipObject *)selectedShip
{
	_selectedShip = selectedShip;
	[self buildSpec];
}

- (NSDictionary *)specDictionary
{
	static NSDictionary *specDictionary = nil;
 
	if(specDictionary) return specDictionary;
	specDictionary = @{
					   @"name" : @"name",
					   @"shortTypeName" : @"shortTypeName",
					   @"slot_0" : @"slot_0",
					   @"slot_1" : @"slot_1",
					   @"slot_2" : @"slot_2",
					   @"slot_3" : @"slot_3",
					   @"slot_4" : @"slot_4",
					   @"onslot_0" : @"onslot_0",
					   @"onslot_1" : @"onslot_1",
					   @"onslot_2" : @"onslot_2",
					   @"onslot_3" : @"onslot_3",
					   @"onslot_4" : @"onslot_4",
					   @"leng" : @"leng",
					   @"slot_ex" : @"slot_ex",
					   @"id" : @"id",
					   };
	return specDictionary;
}
- (void)buildSpec
{
	if(!self.selectedShip) return;
	NSDictionary *spec = self.specDictionary;
	NSMutableArray *array = [NSMutableArray new];
	for(NSString *key in [self specDictionary]) {
		NSMutableDictionary *dict = [NSMutableDictionary new];
		[dict setObject:[self.selectedShip valueForKey:spec[key]] forKey:@"value"];
		[dict setObject:key forKey:@"name"];
		[array addObject:dict];
	}
	
	self.spec = [NSArray arrayWithArray:array];
	
	self.equipments = [self.selectedShip.equippedItem array];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tableview = [notification object];
	NSArrayController *controller = nil;
	if(tableview == self.shipsView) {
		controller = self.shipController;
	}
	if(tableview == self.fleetMemberView) {
		controller = self.fleetMemberController;
	}
	
	NSArray *selectedObjects = controller.selectedObjects;
	if(selectedObjects.count != 0) {
		self.selectedShip = selectedObjects[0];
	}
}


@end

#endif
