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


@property (nonatomic, strong) IBOutlet NSObjectController *kDock1;
@property (nonatomic, strong) IBOutlet NSObjectController *kDock2;
@property (nonatomic, strong) IBOutlet NSObjectController *kDock3;
@property (nonatomic, strong) IBOutlet NSObjectController *kDock4;

@property (nonatomic, strong) NSNumber *kDock1Time;
@property (nonatomic, strong) NSNumber *kDock2Time;
@property (nonatomic, strong) NSNumber *kDock3Time;
@property (nonatomic, strong) NSNumber *kDock4Time;


@property (nonatomic, strong) IBOutlet NSObjectController *deck2;
@property (nonatomic, strong) IBOutlet NSObjectController *deck3;
@property (nonatomic, strong) IBOutlet NSObjectController *deck4;

@property (nonatomic, strong) NSNumber *deck2Time;
@property (nonatomic, strong) NSNumber *deck3Time;
@property (nonatomic, strong) NSNumber *deck4Time;


@end
