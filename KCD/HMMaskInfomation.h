//
//  HMMaskInfomation.h
//  KCD
//
//  Created by Hori,Masaki on 2014/09/06.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMMaskInfomation : NSObject

@property NSRect maskRect;
@property BOOL enable;
@property (strong, nonatomic) NSColor *maskColor;
@property (strong, nonatomic) NSColor *borderColor;
@end
