//
//  HMNyukyoStartCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/09/03.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMNyukyoStartCommand.h"

#import "KCD-Swift.h"


@implementation HMNyukyoStartCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_req_nyukyo/start"]) return YES;
	
	return NO;
}
- (void)execute
{
	id obj = self.arguments[@"api_highspeed"];
	if(!obj) return;
	if(![obj boolValue]) return;
	
	
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	
	NSString *shipId = self.arguments[@"api_ship_id"];
	
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"Ship"
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
