//
//  HMNyukyoSpeedChangeCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/07/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMNyukyoSpeedChangeCommand.h"

#import "KCD-Swift.h"


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
	NSArray *array = [store objectsWithEntityName:@"NyukyoDock"
											error:&error
								  predicateFormat:@"id = %@", @([ndockId integerValue])];
	if(array.count == 0) {
		if(error) {
			NSLog(@"Error: at %@ : %@", NSStringFromClass([self class]), error);
		}
		return;
	}
	
	id dock = array[0];
	
	NSString *shipId = [dock valueForKey:@"ship_id"];
	
	[dock setValue:nil forKey:@"ship_id"];
	[dock setValue:@(0) forKey:@"state"];
	
	
	// 艦隊リスト更新用
	error = nil;
	array = [store objectsWithEntityName:@"Ship"
								   error:&error
						 predicateFormat:@"id = %@", @([shipId integerValue])];
	if(array.count == 0) {
		if(error) {
			NSLog(@"Error: at %@ : %@", NSStringFromClass([self class]), error);
		}
		return;
	}
	
	id ship = array[0];
	[ship setValue:[ship valueForKey:@"maxhp"] forKey:@"nowhp"];
}
@end
