//
//  HMJSONCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONCommand.h"

#import "HMAppDelegate.h"



@implementation HMJSONCommand

+ (HMJSONCommand *)commandForAPI:(NSString *)api
{
	
	[[NSApp delegate] logLineReturn:@"%@", api];
	
	return nil;
}

- (void)doCommand:(id)json
{
	NSLog(@"Enter %s", __PRETTY_FUNCTION__);
	assert(NO);
}

@end
