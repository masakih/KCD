//
//  HMJSONViewCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONViewCommand.h"
#import "HMAppDelegate.h"

#if ENABLE_JSON_LOG


@interface HMJSONViewCommand ()

@end

@implementation HMJSONViewCommand
+ (BOOL)canExcuteAPI:(NSString *)api
{
	return YES;
}

- (void)execute
{
	dispatch_async(dispatch_get_main_queue(), ^{
		HMAppDelegate *appDelegate = [NSApp delegate];
		if(!self.api) {
			NSLog(@"api is nil.");
			return;
		}
		if(!self.argumentArray) {
			NSLog(@"argmentArray is nil.");
			return;
		}
		if(!self.jsonTree) {
			NSLog(@"jsonTree is nil");
			return;
		}
		if(!self.recieveDate) {
			NSLog(@"recieveDate is nil.");
			return;
		}
		[appDelegate.jsonViewWindowController setCommand:@{@"api":self.api,
														   @"argument":self.argumentArray,
														   @"json":self.jsonTree,
														   @"recieveDate":self.recieveDate,
														   @"date": [NSDate dateWithTimeIntervalSinceNow:0]}];
	});
}

@end

#endif
