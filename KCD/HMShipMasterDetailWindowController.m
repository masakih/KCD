//
//  HMShipMasterDetailWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/12/14.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMShipMasterDetailWindowController.h"

#import "HMAppDelegate.h"
#import "HMServerDataStore.h"
#import "HMFleetInformation.h"

#import "KCD-Swift.h"


@interface HMShipMasterDetailWindowController ()

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet NSArrayController *shipController;

@property (strong) NSIndexSet *shipSelectedIndexes;
@property (strong) NSIndexSet *fleetSelectedIndexes;
@property (strong) NSIndexSet *fleetMemberSelectedIndexes;

@property (strong) HMKCShipObject *selectedObject;
@property (strong) NSArray *spec;
@property (strong) NSMutableArray *fleetMember;

@property (strong) NSArray *equipments;

@property (strong) HMFleetInformation *fleetInfo;

@end

@implementation HMShipMasterDetailWindowController
@synthesize shipSelectedIndexes = _shipSelectedIndexes;
@synthesize fleetSelectedIndexes = _fleetSelectedIndexes;
@synthesize fleetMemberSelectedIndexes = _fleetMemberSelectedIndexes;
@synthesize selectedObject = _selectedObject;


- (instancetype)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		HMAppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
		_fleetInfo = appDelegate.fleetInformation;
		_fleetMember = [NSMutableArray new];
		[self buildFleet];
	}
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (void)setShipSelectedIndexes:(NSIndexSet *)shipSelectedIndexes
{
	_shipSelectedIndexes = shipSelectedIndexes;
	if(!shipSelectedIndexes) return;
	self.selectedObject = [self.shipController.arrangedObjects objectAtIndex:shipSelectedIndexes.firstIndex];
}
- (NSIndexSet *)shipSelectedIndexes
{
	return _shipSelectedIndexes;
}
- (void)setFleetSelectedIndexes:(NSIndexSet *)fleetSelectedIndexes
{
	_fleetSelectedIndexes = fleetSelectedIndexes;
	[self buildFleet];
}
- (NSIndexSet *)fleetSelectedIndexes
{
	return _fleetSelectedIndexes;
}
- (void)setFleetMemberSelectedIndexes:(NSIndexSet *)fleetMemberSelectedIndexes
{
	_fleetMemberSelectedIndexes = fleetMemberSelectedIndexes;
	if(!fleetMemberSelectedIndexes) return;
	if(fleetMemberSelectedIndexes.firstIndex > self.fleetMember.count) return;
	self.selectedObject = [self.fleetMember objectAtIndex:fleetMemberSelectedIndexes.firstIndex];
}
- (NSIndexSet *)fleetMemberSelectedIndexes
{
	return _fleetMemberSelectedIndexes;
}

- (void)setSelectedObject:(HMKCShipObject *)selectedObject
{
	if([_selectedObject isEqual:selectedObject]) return;
	_selectedObject = selectedObject;
	[self.shipController setSelectedObjects:@[selectedObject]];
	[self buildSpec];
}
- (HMKCShipObject *)selectedObject
{
	return _selectedObject;
}

- (void)buildFleet
{
	self.fleetMember = [[self.fleetInfo fleetMemberAtIndex:self.fleetSelectedIndexes.firstIndex + 1] mutableCopy];
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
					   };
	return specDictionary;
}
- (void)buildSpec
{
	if(!self.selectedObject) return;
	NSDictionary *spec = self.specDictionary;
	NSMutableArray *array = [NSMutableArray new];
	for(NSString *key in [self specDictionary]) {
		NSMutableDictionary *dict = [NSMutableDictionary new];
		[dict setObject:[self.selectedObject valueForKey:spec[key]] forKey:@"value"];
		[dict setObject:key forKey:@"name"];
		[array addObject:dict];
	}
	
	self.spec = [NSArray arrayWithArray:array];
	
	self.equipments = [self.selectedObject.equippedItem array];
}


@end
