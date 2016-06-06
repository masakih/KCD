//
//  HMScreenshotModel.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/03/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotModel.h"

@implementation HMScreenshotModel

- (id)description
{
	return [NSString stringWithFormat:
			@"screenshot count -> %ld\n"
			@"sortDescriptors -> %@\n"
			@"selectionIndexes -> %@\n"
			@"filterPredicate -> %@",
			self.screenshots.count,
			self.sortDescriptors,
			self.selectedIndexes,
			self.filterPredicate];
}

@end
