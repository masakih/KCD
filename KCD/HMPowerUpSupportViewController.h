//
//  HMPowerUpSupportViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/06.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMPowerUpSupportViewController : NSViewController
@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (assign) IBOutlet NSArrayController *shipController;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *typeSegment;


- (IBAction)changeCategory:(id)sender;

@end
