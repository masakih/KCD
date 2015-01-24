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
@property (nonatomic, strong) IBOutlet NSScrollView *expTableView;
@property (nonatomic, strong) IBOutlet NSScrollView *powerTableView;
@property (nonatomic, strong) IBOutlet NSScrollView *power2TableView;


- (IBAction)changeCategory:(id)sender;

- (IBAction)changeView:(id)sender;

@end
