//
//  HMDeckViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/04/12.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMDeckViewController : NSViewController

@property (readonly) NSManagedObjectContext *manageObjectContext;

@property (weak, nonatomic) IBOutlet NSArrayController *deckController;
@property (weak, nonatomic) IBOutlet NSArrayController *shipsController;

@property (weak, nonatomic) IBOutlet NSArrayController *ship1Controller;
@property (weak, nonatomic) IBOutlet NSArrayController *ship2Controller;
@property (weak, nonatomic) IBOutlet NSArrayController *ship3Controller;
@property (weak, nonatomic) IBOutlet NSArrayController *ship4Controller;
@property (weak, nonatomic) IBOutlet NSArrayController *ship5Controller;
@property (weak, nonatomic) IBOutlet NSArrayController *ship6Controller;

@property NSInteger selectedDeck;
@end
