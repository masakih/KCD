//
//  HMAncherageRepairTimerViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/03/06.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAncherageRepairTimerViewController.h"

#import "HMAppDelegate.h"

#import "HMAnchorageRepairManager.h"

@interface HMAncherageRepairTimerViewController ()
@property (strong) HMAnchorageRepairManager *anchorageRepairManager;
@property (strong) NSNumber *repairTime;
@end

@implementation HMAncherageRepairTimerViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		_anchorageRepairManager = [HMAnchorageRepairManager defaultManager];
		
		HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
		[appDelegate addCounterUpdateBlock:^{
			self.repairTime = [self calcRepairTime];
		}];
	}
	
	return self;
}

- (NSNumber *)calcRepairTime
{
	NSDate *compTimeValue = self.anchorageRepairManager.repairTime;
	if(!compTimeValue) return nil;
	
	NSTimeInterval compTime = [compTimeValue timeIntervalSince1970];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	return @(diff + 20 * 60);
}
@end
