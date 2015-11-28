//
//  HMCombinedCommand.h
//  KCD
//
//  Created by Hori,Masaki on 2015/11/26.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMJSONCommand.h"

typedef NS_ENUM(NSUInteger, CombineType) {
	cancel,
	maneuver,
	water,
	transportation,
};

@interface HMCombinedCommand : HMJSONCommand

@end

extern NSString *HMCombinedCommandCombinedDidCangeNotification;
extern NSString		*HMCombinedType;	// NSNumber of CombineType
