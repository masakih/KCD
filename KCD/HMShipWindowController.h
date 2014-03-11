//
//  HMShipWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMShipWindowController : NSWindowController

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet NSArrayController *shipController;


- (IBAction)changeCategory:(id)sender;

@end
