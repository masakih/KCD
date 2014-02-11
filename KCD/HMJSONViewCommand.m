//
//  HMJSONViewCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONViewCommand.h"
#import "HMAppDelegate.h"


@interface HMJSONViewCommand ()

@end

@implementation HMJSONViewCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return YES;// [api isEqualToString:@"/kcsapi/api_req_member/get_incentive"];
}

- (id)init
{
	self = [super init];
	if(self) {
		
	}
	
	return self;
}

- (void)doCommand:(id)json
{
	self.json = json;
	
	HMAppDelegate *appDelegate = [NSApp delegate];
	[appDelegate.jsonViewWindowController setCommand:@{@"api":self.api, @"argument":self.arguments, @"json":self.json, @"date": [NSDate date]}];
}


@end
