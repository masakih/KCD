//
//  HMMemberDeckCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberDeckCommand.h"

/* 
 mission_0:	status
	0:ミッション無し
	1:ミッション中
	2:帰投 (おそらく帰投時のデータ確認用か帰投表示を出すため）
 
 mission_1: maparea_id
 mission_2: 帰投時間
 mission_3: 未使用？
 */

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
	if([api isEqualToString:@"/kcsapi/api_req_hensei/preset_select"]) return YES;
	return NO;
}

- (NSString *)dataKey
{
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]) {
		return @"api_data.api_deck_port";
	}
	if([self.api isEqualToString:@"/kcsapi/api_get_member/ship2"]) {
		return @"api_data_deck";
	}
	if([self.api isEqualToString:@"/kcsapi/api_get_member/ship3"]) {
		return @"api_data.api_deck_data";
	}
	if([self.api isEqualToString:@"/kcsapi/api_get_member/ship_deck"]) {
		return @"api_data.api_deck_data";
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_hensei/preset_select"]) {
		return [super dataKey];
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_kaisou/powerup"]) {
		return @"api_data.api_deck";
	}
	
	return [super dataKey];
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"Deck"];
}
@end
