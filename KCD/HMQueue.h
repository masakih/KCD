//
//  HMQueue.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMQueue : NSObject

- (id)dequeue;
- (void)enqueue:(id)object;

@end
