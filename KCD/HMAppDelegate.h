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

- (IBAction)showHideHistory:(id)sender;


#if ENABLE_JSON_LOG
@property (strong) HMJSONViewWindowController *jsonViewWindowController;
#endif
#ifdef DEBUG
- (IBAction)saveLocalData:(id)sender;
- (IBAction)loadLocalData:(id)sender;
#endif
@end
