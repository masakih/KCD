//
//  HMExternalBrowserWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/11/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>


@interface HMExternalBrowserWindowController : NSWindowController

@property (nonatomic, weak) IBOutlet WebView *webView;

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSString *urlString;
@property (nonatomic) NSSize windowContentSize;
@property (readonly) NSRect contentVisibleRect;
@property BOOL canResize;
@property BOOL canScroll;

- (IBAction)clickGoBackSegment:(id)sender;

- (IBAction)addBookmark:(id)sender;
- (IBAction)editBookmark:(id)sender;
- (IBAction)showBookmark:(id)sender;

- (IBAction)selectBookmark:(id)sender;

@end
