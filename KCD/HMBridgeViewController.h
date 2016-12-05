//
//  HMBridgeViewController.h
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/03/30.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMScreenshotInformation.h"

@interface HMBridgeViewController : NSViewController <NSSharingServicePickerTouchBarItemDelegate, NSSharingServiceDelegate>
@property (nonatomic, strong) IBOutlet NSArrayController *arrayController;

// for sharing service
@property (readonly) NSRect contentRect;

@property (readonly) BOOL appendKanColleTag;
@property (readonly) NSString *tagString;

- (IBAction)share:(id)sender;
@end
