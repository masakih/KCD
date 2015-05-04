//
//  HMQuestListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/04/15.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMQuestListViewController.h"

#import "HMServerDataStore.h"

@interface HMQuestListViewController ()

@property (readonly) NSManagedObjectContext *managedObjectContext;
@end

@implementation HMQuestListViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

@end
