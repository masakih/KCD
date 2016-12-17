//
//  HMDummyShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/19.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMDummyShipCommand.h"

#import "HMServerDataStore.h"
#import "HMKCShipObject+Extensions.h"


@implementation HMDummyShipCommand

static BOOL getShipFlag = 0;

- (void)checkGetShip
{
	id data = [self.json valueForKey:@"api_data"];
	id getShip = [data valueForKey:@"api_get_ship"];
	if(!getShip || [getShip isKindOfClass:[NSNull class]]) return;
	
	getShipFlag = YES;
}
- (void)enterDummy
{
	if(!getShipFlag) return;
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	
	HMKCShipObject *object = [serverDataStore insertNewObjectForEntityForName:@"Ship"];
	object.id = @(-2);
	getShipFlag = NO;
}

- (void)removeDummy
{
	getShipFlag = NO;
	
	NSError *error = nil;
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSArray<HMKCShipObject *> *dummys = [serverDataStore objectsWithEntityName:@"Ship"
																		 error:&error
															   predicateFormat:@"id = %@", @(-2)];
	for(HMKCShipObject *dummy in dummys) {
		[serverDataStore deleteObject:dummy];
	}
}

- (void)execute
{
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/battleresult"]) {
		[self checkGetShip];
	}
	if([self.api isEqualToString:@"/kcsapi/api_get_member/ship_deck"]) {
		[self enterDummy];
	}
	if([self.api isEqualToString:@"/kcsapi/api_port/port"]) {
		[self removeDummy];
	}
}

@end
