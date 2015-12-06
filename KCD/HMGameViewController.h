//
//  HMGameViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2015/12/06.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMGameViewController : NSViewController

- (IBAction)reloadContent:(id)sender;
- (IBAction)deleteCacheAndReload:(id)sender;
- (IBAction)screenShot:(id)sender;

@end
