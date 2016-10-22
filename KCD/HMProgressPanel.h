//
//  HMProgressPanel.h
//  KCD
//
//  Created by Hori,Masaki on 2015/06/25.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMProgressPanel : NSWindowController

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property BOOL animate;

@end
