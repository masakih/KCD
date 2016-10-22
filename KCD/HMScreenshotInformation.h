//
//  HMScreenshotInformation.h
//  KCD
//
//  Created by Hori,Masaki on 2014/11/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMScreenshotInformation : NSObject <NSCoding>
@property (copy) NSString *path;
@property (readonly) NSString *name;
@property (strong) NSDate *creationDate;
@property NSUInteger version;
@property (nonatomic, copy) NSArray<NSString *> *tags;
@end
