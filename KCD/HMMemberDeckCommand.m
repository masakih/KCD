//
//  HMMemberDeckCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberDeckCommand.h"

@implementation HMMemberDeckCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_get_member/deck"]) return YES;
	if([api isEqualToString:@"/kcsapi/api_get_member/deck_port"]) return YES;
	return NO;
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"Deck"];
}
@end
