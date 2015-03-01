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

@end

@implementation HMShipDetailViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
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



- (IBAction)changeShip:(id)sender
{
	NSInteger shipId = self.shipID.integerValue;
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	
	NSArray *array = [store objectsWithEntityName:@"Ship"
											error:NULL
								  predicateFormat:@"id = %ld", shipId];
	if(array.count == 0) {
		return;
	}
	
	self.ship = array[0];
}

@end
