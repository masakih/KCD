//
//  HMDocksViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDocksViewController.h"

#import "HMServerDataStore.h"

#import "HMMissionStatus.h"
#import "HMNyukyoDockStatus.h"
#import "HMKenzoDockStatus.h"


@interface HMDocksViewController ()

@property (strong) HMMissionStatus *mission2Status;
@property (strong) HMMissionStatus *mission3Status;
@property (strong) HMMissionStatus *mission4Status;

@property (strong) HMNyukyoDockStatus *ndock1Status;
@property (strong) HMNyukyoDockStatus *ndock2Status;
@property (strong) HMNyukyoDockStatus *ndock3Status;
@property (strong) HMNyukyoDockStatus *ndock4Status;

@property (strong) HMKenzoDockStatus *kdock1Status;
@property (strong) HMKenzoDockStatus *kdock2Status;
@property (strong) HMKenzoDockStatus *kdock3Status;
@property (strong) HMKenzoDockStatus *kdock4Status;


@end

@implementation HMDocksViewController


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		_mission2Status = [[HMMissionStatus alloc] initWithDeckNumber:2];
		_mission2Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"deck2Time" toObject:self.mission2Status withKeyPath:@"time" options:nil];
		[self bind:@"mission2Name" toObject:self.mission2Status withKeyPath:@"name" options:nil];
		
		_mission3Status = [[HMMissionStatus alloc] initWithDeckNumber:3];
		_mission3Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"deck3Time" toObject:self.mission3Status withKeyPath:@"time" options:nil];
		[self bind:@"mission3Name" toObject:self.mission3Status withKeyPath:@"name" options:nil];
		
		_mission4Status = [[HMMissionStatus alloc] initWithDeckNumber:4];
		_mission4Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"deck4Time" toObject:self.mission4Status withKeyPath:@"time" options:nil];
		[self bind:@"mission4Name" toObject:self.mission4Status withKeyPath:@"name" options:nil];
		
		
		//
		_ndock1Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:1];
		_ndock1Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock1Time" toObject:self.ndock1Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock1ShipName" toObject:self.ndock1Status withKeyPath:@"name" options:nil];
		
		_ndock2Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:2];
		_ndock2Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock2Time" toObject:self.ndock2Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock2ShipName" toObject:self.ndock2Status withKeyPath:@"name" options:nil];
		
		_ndock3Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:3];
		_ndock3Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock3Time" toObject:self.ndock3Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock3ShipName" toObject:self.ndock3Status withKeyPath:@"name" options:nil];
		
		_ndock4Status = [[HMNyukyoDockStatus alloc] initWithDockNumber:4];
		_ndock4Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"nDock4Time" toObject:self.ndock4Status withKeyPath:@"time" options:nil];
		[self bind:@"nDock4ShipName" toObject:self.ndock4Status withKeyPath:@"name" options:nil];
		
		
		//
		_kdock1Status = [[HMKenzoDockStatus alloc] initWithDockNumber:1];
		_kdock1Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"kDock1Time" toObject:self.kdock1Status withKeyPath:@"time" options:nil];
		
		_kdock2Status = [[HMKenzoDockStatus alloc] initWithDockNumber:2];
		_kdock2Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"kDock2Time" toObject:self.kdock2Status withKeyPath:@"time" options:nil];
		
		_kdock3Status = [[HMKenzoDockStatus alloc] initWithDockNumber:3];
		_kdock3Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"kDock3Time" toObject:self.kdock3Status withKeyPath:@"time" options:nil];
		
		_kdock4Status = [[HMKenzoDockStatus alloc] initWithDockNumber:4];
		_kdock4Status.managedObjectContext = self.managedObjectContext;
		[self bind:@"kDock4Time" toObject:self.kdock4Status withKeyPath:@"time" options:nil];
	}
	return self;
}

- (void)awakeFromNib
{
	[NSTimer scheduledTimerWithTimeInterval:0.33
									 target:self
								   selector:@selector(fire:)
								   userInfo:nil
									repeats:YES];
}


- (void)fire:(id)timer
{
	// 入渠ドック
	[self.ndock1Status update];
	[self.ndock2Status update];
	[self.ndock3Status update];
	[self.ndock4Status update];
	
	// 建造ドック
	[self.kdock1Status update];
	[self.kdock2Status update];
	[self.kdock3Status update];
	[self.kdock4Status update];
	
	// 遠征
	[self.mission2Status update];
	[self.mission3Status update];
	[self.mission4Status update];
}

- (NSString *)firstFleetName
{
	return @"First Fleet Name";
}
- (NSString *)areaName
{
	return @"ABCDEFGHIJKLMN";
}
- (NSString *)areaNumber
{
	return @"5-5";
}

@end
