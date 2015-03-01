//
//  HMShipDetailViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2015/02/28.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMSuppliesView;
@class HMKCShipObject;

@interface HMShipDetailViewController : NSViewController

@property (strong) HMKCShipObject *ship;

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet HMSuppliesView *supply;


@property (nonatomic, weak) IBOutlet NSTextField *shipID;
- (IBAction)changeShip:(id)sender;
@end
