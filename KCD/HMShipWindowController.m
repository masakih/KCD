//
//  HMShipWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMShipWindowController.h"

#import "HMAppDelegate.h"
#import "HMServerDataStore.h"


@interface HMShipWindowController ()

@end

@implementation HMShipWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

@end
