//
//  HMBroserWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>


@interface HMBroserWindowController : NSWindowController

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSView *placeholder;

@property (readonly) NSAttributedString *linksString;

@property (nonatomic, strong) IBOutlet NSArrayController *deckContoller;
@property (nonatomic, readonly) NSString *flagShipName;


@property (nonatomic, weak) IBOutlet NSView *deckPlaceholder;

@property (nonatomic, strong) IBOutlet NSArrayController *shipController;
@property (nonatomic, strong) IBOutlet NSObjectController *basicController;
@property (nonatomic, strong) NSNumber *maxChara;
@property (nonatomic, strong) NSNumber *shipCount;
@property (readonly) NSColor *shipNumberColor;
@property NSInteger minimumColoredShipCount;


- (IBAction)reloadContent:(id)sender;

@end
