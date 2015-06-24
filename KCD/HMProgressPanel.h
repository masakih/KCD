//
//  HMProgressPanel.h
//  KCD
//
//  Created by Hori,Masaki on 2015/06/25.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMProgressPanel : NSWindowController

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property BOOL animate;

@end
