//
//  HMAppDelegate.h
//  KCD
//
//  Created by Hori,Masaki on 2013/12/31.
//  Copyright (c) 2013年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMJSONViewWindowController.h"


@interface HMAppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (void)logLineReturn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);


@property (retain) HMJSONViewWindowController *jsonViewWindowController;

@end
