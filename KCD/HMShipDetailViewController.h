//
//  HMShipDetailViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2015/02/28.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMKCShipObject;

@interface HMShipDetailViewController : NSViewController

@property (strong) HMKCShipObject *ship;

@property (nonatomic) BOOL guardEscaped;

@end
