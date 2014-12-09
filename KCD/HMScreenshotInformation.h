//
//  HMScreenshotInformation.h
//  KCD
//
//  Created by Hori,Masaki on 2014/11/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMScreenshotInformation : NSObject
@property (strong) NSString *path;
@property (readonly) NSString *name;
@property (strong) NSDate *creationDate;
@property NSUInteger version;
@end
