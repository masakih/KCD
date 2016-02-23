//
//  HMAnchorageRepairManager.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/20.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMAnchorageRepairManager : NSObject

+ (instancetype)defaultManager;

@property (readonly) NSDate *repairTime;

@end
