//
//  HMHistoryWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMHistoryWindowController.h"

#import "HMLocalDataStore.h"


@interface HMHistoryWindowController ()

@end

@implementation HMHistoryWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	
	return self;
}

- (NSManagedObjectContext *)manageObjectContext
{
	return [[HMLocalDataStore defaultManager] managedObjectContext];
}

@end
