//
//  HMShipWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMShipWindowController.h"

#import "HMAppDelegate.h"

#import "KCD-Swift.h"


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

- (IBAction)changeMissionTime:(id)sender
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSError *error = nil;
	
	NSArray *decks = [store objectsWithEntityName:@"Deck"
								  sortDescriptors:nil
										predicate:[NSPredicate predicateWithFormat:@"id = %@", self.missionFleetNumber]
											error:&error];
	if(decks.count == 0) return;
	id deck = decks[0];
	
	NSInteger time = [self.missionTime doubleValue];
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:time];
	time = [date timeIntervalSince1970];
	time *= 1000.0;
	[deck setValue:@(time) forKey:@"mission_2"];
}

@end
