//
//  HMMaskSelectView.h
//  KCD
//
//  Created by Hori,Masaki on 2014/09/05.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMMaskSelectView : NSView

@property (nonatomic, copy) NSMutableArray *masks;

- (IBAction)disableAllMasks:(id)sender;

@end
