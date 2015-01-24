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
	kKenzoHistoryIndex = 1
};

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

@end
