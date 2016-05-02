//
//  HMPreferencePanelController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/09/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMPreferencePanelController : NSWindowController

@property (readonly) NSString *screenShotSaveDirectory;


@property (nonatomic, weak) IBOutlet NSPopUpButton *screenShotSaveDirectoryPopUp;

- (IBAction)selectScreenShotSaveDirectory:(id)sender;

- (IBAction)selectScreenShotSaveDirectoryPopUp:(id)sender;

@end
