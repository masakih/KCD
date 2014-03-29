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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}


- (IBAction)changeCategory:(id)sender
{
	NSArray *categories = [[NSApp delegate] shipTypeCategories];
	
	NSPredicate *predicate = nil;
	NSUInteger tag = [sender selectedSegment];
	if(tag != 0 && tag < 8) {
		predicate = [NSPredicate predicateWithFormat:@"master_ship.stype.id  in %@", categories[tag - 1]];
	}
	[self.shipController setFetchPredicate:predicate];
	[self.shipController rearrangeObjects];
}

@end
