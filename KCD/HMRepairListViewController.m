//
//  HMRepairListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/02.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMRepairListViewController.h"

#import "HMAppDelegate.h"
#import "HMServerDataStore.h"

#import "HMAnchorageRepairManager.h"



@interface HMRepairListViewController ()
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly) NSPredicate *fetchPredicate;
@property (strong) HMAnchorageRepairManager *anchorageRepairManager;

@property (strong) NSNumber *repairTime;
@end

@implementation HMRepairListViewController
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
- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}
- (NSPredicate *)fetchPredicate
{
	return [NSPredicate predicateWithFormat:@"NOT ndock_time is %@", @0];
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
