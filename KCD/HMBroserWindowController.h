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

@property (nonatomic, weak) IBOutlet NSView *docksPlaceholder;

@property (readonly) NSAttributedString *linksString;

@property NSInteger selectedViewsSegment;


- (IBAction)reloadContent:(id)sender;
- (IBAction)selectView:(id)sender;


@end
