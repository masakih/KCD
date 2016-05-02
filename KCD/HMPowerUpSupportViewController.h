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

@property (nonatomic, strong) IBOutlet NSArrayController *shipController;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *typeSegment;


- (IBAction)changeCategory:(id)sender;

@end
