//
//  HMRepairListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/02.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMRepairListViewController.h"

#import "HMServerDataStore.h"

@interface HMRepairListViewController ()
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly) NSPredicate *fetchPredicate;
@end

@implementation HMRepairListViewController
- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}
- (NSPredicate *)fetchPredicate
{
	return [NSPredicate predicateWithFormat:@"NOT ndock_time is %@", @0];
}
@end
