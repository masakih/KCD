//
//  HMScreenshotModel.h
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/03/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMScreenshotModel : NSObject
@property (strong) NSArray *screenshots;
@property (strong) NSArray *sortDescriptors;
@property (strong) NSIndexSet *selectedIndexes;
@property (strong) NSPredicate *filterPredicate;
@end
