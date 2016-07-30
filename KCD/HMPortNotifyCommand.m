//
//  HMPortNotifyCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/07/21.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMPortNotifyCommand.h"


NSString *HMPortAPIRecieveNotification = @"HMPortAPIRecieveNotification";

@implementation HMPortNotifyCommand

- (void)execute
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:HMPortAPIRecieveNotification
						  object:self
						userInfo:nil];
	});
}

@end
