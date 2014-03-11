//
//  HMShipViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/04.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMShipViewController : NSViewController
@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet NSArrayController *shipController;


- (IBAction)changeCategory:(id)sender;

@end
