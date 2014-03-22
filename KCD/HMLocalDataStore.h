//
//  HMLocalDataStore.h
//  KCD
//
//  Created by Hori,Masaki on 2014/03/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMLocalDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (instancetype)defaultManager;
+ (instancetype)oneTimeEditor;

- (IBAction)saveAction:(id)sender;

@end
