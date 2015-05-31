//
//  HMBookmarkListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/30.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkListViewController.h"

#import "HMBookmarkManager.h"


@interface HMBookmarkListViewController ()

- (NSManagedObjectContext *)managedObjectContext;

@end

@implementation HMBookmarkListViewController

- (instancetype)init
{
	self = [super initWithNibName:NSStringFromClass([self class])
						   bundle:nil];
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMBookmarkManager sharedManager].manageObjectContext;
}


@end
