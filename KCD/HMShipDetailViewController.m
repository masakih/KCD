//
//  HMShipDetailViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/02/28.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMShipDetailViewController.h"
#import "HMSuppliesView.h"

#import "HMServerDataStore.h"

@interface HMShipDetailViewController ()

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet HMSuppliesView *supply;

@property (nonatomic, weak) IBOutlet NSView *taihiOverlayView;

@property (nonatomic, weak) IBOutlet NSObjectController *shipController;
@property (nonatomic, weak) IBOutlet NSTextField *slot00Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot01Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot02Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot03Field;

@end

@implementation HMShipDetailViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (void)awakeFromNib
{
	[self.slot00Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_0"
				   options:nil];
	[self.slot01Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_1"
				   options:nil];
	[self.slot02Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_2"
				   options:nil];
	[self.slot03Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_3"
				   options:nil];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (void)setShip:(HMKCShipObject *)ship
{
	self.representedObject = ship;
	
	self.supply.shipStatus = ship;
}
- (HMKCShipObject *)ship
{
	return self.representedObject;
}

@end
