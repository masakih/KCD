//
//  HMChangeHenseiNotification.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/21.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMChangeHenseiNotification.h"


NSString *HMChangeHenseiNotification = @"HMChangeHenseiNotification";
NSString *HMChangeHenseiUserInfoKey = @"HMChangeHenseiUserInfoKey";


@implementation HMChangeHenseiNotificationUserInfo

- (id)description
{
	NSString *format = @"HMChangeHenseiNotificationUserInfo<%p> = {\n"
	@"type = %ld\n"
	@"fleetNumber = %@\n"
	@"position = %@\n"
	@"shipID = %@\n"
	@"replaceFleetNumber = %@\n"
	@"replacePosition = %@\n"
	@"replaceShipID = %@ }";
	
	return [NSString stringWithFormat:format,
			self,
			_type,
			_fleetNumber,
			_position,
			_shipID,
			_replaceFleetNumber,
			_replacePosition,
			_replaceShipID];
}

@end
