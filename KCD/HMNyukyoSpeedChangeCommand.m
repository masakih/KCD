//
//  HMNyukyoSpeedChangeCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/07/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMNyukyoSpeedChangeCommand.h"

#import "HMServerDataStore.h"
#import "HMKCNyukyoDock.h"
#import "HMKCShipObject+Extensions.h"


@implementation HMNyukyoSpeedChangeCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_nyukyo/speedchange"]) return YES;
	
	return NO;
}
- (void)execute
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	
	NSString *ndockId = self.arguments[@"api_ndock_id"];
	
	NSError *error = nil;
	NSArray<HMKCNyukyoDock *> *nyukyoDocks = [store objectsWithEntityName:@"NyukyoDock"
															  error:&error
														  predicateFormat:@"id = %@", @([ndockId integerValue])];
	if(nyukyoDocks.count == 0) {
		if(error) {
			NSLog(@"Error: at %@ : %@", NSStringFromClass([self class]), error);
		}
		return;
	}
	
	NSNumber *shipId = nyukyoDocks[0].ship_id;
	
	nyukyoDocks[0].ship_id = nil;
	nyukyoDocks[0].state = @(0);
	
	// 艦隊リスト更新用
	error = nil;
	NSArray<HMKCShipObject *> *ships = [store objectsWithEntityName:@"Ship"
															  error:&error
													predicateFormat:@"id = %@", @([shipId integerValue])];
	if(ships.count == 0) {
		if(error) {
			NSLog(@"Error: at %@ : %@", NSStringFromClass([self class]), error);
		}
		return;
	}
	
	ships[0].nowhp = ships[0].maxhp;
}
@end
