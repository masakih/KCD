//
//  HMKenzoDockStatus.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMKenzoDockStatus : NSObject

- (id)initWithDockNumber:(NSInteger)dockNumber;

@property (assign) NSManagedObjectContext *managedObjectContext;

@property (readonly) NSNumber *time;
@property (readonly) BOOL isTasking;
@property (readonly) BOOL didNotify;

- (void)update;
@end
