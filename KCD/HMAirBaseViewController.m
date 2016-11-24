//
//  HMAirBaseViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAirBaseViewController.h"

#import "HMServerDataStore.h"

@interface HMAirBaseViewController ()

@end

@implementation HMAirBaseViewController

- (NSManagedObjectContext *)managedObjectContext
{
    return [HMServerDataStore defaultManager].managedObjectContext;
}

@end
