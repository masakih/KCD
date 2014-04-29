//
//  HMAppDelegate.h
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMJSONViewWindowController.h"


@interface HMAppDelegate : NSObject <NSApplicationDelegate>


- (void)logLineReturn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@property (readonly) NSArray *shipTypeCategories;

@property (strong, nonatomic) IBOutlet NSMenuItem *debugMenuItem;

- (IBAction)showHideHistory:(id)sender;
- (IBAction)showHideSlotItemWindow:(id)sender;

- (IBAction)saveLocalData:(id)sender;
- (IBAction)loadLocalData:(id)sender;

#if ENABLE_JSON_LOG
@property (strong) HMJSONViewWindowController *jsonViewWindowController;
#endif

@end
