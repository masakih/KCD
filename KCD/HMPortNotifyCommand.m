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
	[self performSelectorOnMainThread:@selector(notifyOnMainThread:)
						   withObject:nil
						waitUntilDone:NO];
}

- (void)notifyOnMainThread:(id)dummy
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:HMPortAPIRecieveNotification
					  object:self
					userInfo:nil];
}
@end
