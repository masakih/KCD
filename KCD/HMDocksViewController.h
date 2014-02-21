//
//  HMDocksViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMDocksViewController : NSViewController

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet NSObjectController *nDock1;
@property (nonatomic, strong) IBOutlet NSObjectController *nDock2;
@property (nonatomic, strong) IBOutlet NSObjectController *nDock3;
@property (nonatomic, strong) IBOutlet NSObjectController *nDock4;

@property (nonatomic, strong) NSNumber *nDock1Time;
@property (nonatomic, strong) NSNumber *nDock2Time;
@property (nonatomic, strong) NSNumber *nDock3Time;
@property (nonatomic, strong) NSNumber *nDock4Time;


@end
