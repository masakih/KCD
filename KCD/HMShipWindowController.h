//
//  HMShipWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/24.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMShipWindowController : NSWindowController

@property (readonly) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, strong) NSNumber *missionFleetNumber;
@property (nonatomic, strong) NSNumber *missionTime;
- (IBAction)changeMissionTime:(id)sender;
@end
