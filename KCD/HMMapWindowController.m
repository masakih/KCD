//
//  HMMapWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/01/24.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#ifdef DEBUG


#import "HMMapWindowController.h"

#import "HMServerDataStore.h"


@implementation HMMapWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}


@end

#endif
