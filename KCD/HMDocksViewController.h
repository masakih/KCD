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

@property (readonly) NSString *nDock1ShipName;
@property (readonly) NSString *nDock2ShipName;
@property (readonly) NSString *nDock3ShipName;
@property (readonly) NSString *nDock4ShipName;


@property (nonatomic, strong) IBOutlet NSObjectController *kDock1;
@property (nonatomic, strong) IBOutlet NSObjectController *kDock2;
@property (nonatomic, strong) IBOutlet NSObjectController *kDock3;
@property (nonatomic, strong) IBOutlet NSObjectController *kDock4;

@property (nonatomic, strong) NSNumber *kDock1Time;
@property (nonatomic, strong) NSNumber *kDock2Time;
@property (nonatomic, strong) NSNumber *kDock3Time;
@property (nonatomic, strong) NSNumber *kDock4Time;


@property (readonly) NSNumber *deck2Time;
@property (readonly) NSNumber *deck3Time;
@property (readonly) NSNumber *deck4Time;

@property (readonly) NSString *mission2Name;
@property (readonly) NSString *mission3Name;
@property (readonly) NSString *mission4Name;

@end
