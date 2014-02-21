//
//  HMDocksViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDocksViewController.h"

#import "HMCoreDataManager.h"

@interface HMDocksViewController ()

@end

@implementation HMDocksViewController


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
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

- (NSNumber *)nDockTimeForNDock:(NSObjectController *)nDock
{
	[nDock prepareContent];
	NSNumber *compTimeValue = [nDock valueForKeyPath:@"selection.complete_time"];
	if(![compTimeValue isKindOfClass:[NSNumber class]]) return nil;
	
	if(![compTimeValue isEqualToNumber:@0]) {
		NSTimeInterval compTime = (NSUInteger)([compTimeValue doubleValue] / 1000.0);
		NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
		NSTimeInterval diff = compTime - [now timeIntervalSince1970];
		
		if(diff < 0) {
			return @( - [[NSTimeZone systemTimeZone] secondsFromGMT]);
		} else {
			return @(diff - [[NSTimeZone systemTimeZone] secondsFromGMT]);
		}
	}
	return nil;
}
- (void)fire:(id)timer
{
	self.nDock1Time = [self nDockTimeForNDock:self.nDock1];
	self.nDock2Time = [self nDockTimeForNDock:self.nDock2];
	self.nDock3Time = [self nDockTimeForNDock:self.nDock3];
	self.nDock4Time = [self nDockTimeForNDock:self.nDock4];
}
@end
