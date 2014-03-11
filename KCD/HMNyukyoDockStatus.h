//
//  HMNyukyoDockStatus.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMNyukyoDockStatus : NSObject

- (id)initWithDockNumber:(NSInteger)dockNumber;

@property (weak) NSManagedObjectContext *managedObjectContext;

@property (readonly) NSString *name;
@property (readonly) NSNumber *time;
@property (readonly) BOOL isTasking;
@property (readonly) BOOL didNotify;

- (void)update;
@end
