//
//  HMIgnoreCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/10/09.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMIgnoreCommand.h"

static NSArray *ignoreCommands = nil;

@implementation HMIgnoreCommand

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSURL *url = [mainBundle URLForResource:@"HMIgnoreCommand"
								  withExtension:@"plist"];
		NSArray *array = [NSArray arrayWithContentsOfURL:url];
		
		ignoreCommands = array;
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [ignoreCommands containsObject:api];
}

- (void)execute
{
	// do nothing
}
@end
