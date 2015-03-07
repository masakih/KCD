//
//  HMMinimumShipViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/06.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMMinimumShipViewController.h"
#import "HMSuppliesView.h"

#import "HMServerDataStore.h"

@interface HMMinimumShipViewController ()

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet HMSuppliesView *supply;

@end

@implementation HMMinimumShipViewController
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

@end
