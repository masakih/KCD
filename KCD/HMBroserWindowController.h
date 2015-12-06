//
//  HMBroserWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMBroserWindowController : NSWindowController

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet NSView *placeholder;

@property (weak) IBOutlet NSView *combinedViewPlaceholder;

@property (readonly) NSAttributedString *linksString;

@property (nonatomic, strong) IBOutlet NSArrayController *deckContoller;
@property (nonatomic, readonly) NSString *flagShipName;

@property (nonatomic, weak) IBOutlet NSView *deckPlaceholder;

@end
