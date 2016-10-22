//
//  HMScreenshotModel.h
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/03/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMScreenshotInformation.h"

@interface HMScreenshotModel : NSObject
@property (copy) NSArray<HMScreenshotInformation *> *screenshots;
@property (copy) NSArray<NSSortDescriptor *> *sortDescriptors;
@property (copy) NSIndexSet *selectedIndexes;
@property (strong) NSPredicate *filterPredicate;
@end
