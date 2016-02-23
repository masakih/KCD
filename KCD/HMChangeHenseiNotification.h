//
//  HMChangeHenseiNotification.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/21.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HMChangeHenseiType) {
	kHMChangeHenseiAppend,
	kHMChangeHenseiReplace,
	kHMChangeHenseiRemove,
	
	kHMChangeHenseiRemoveAllWithoutFlagship,
};

@interface HMChangeHenseiNotificationUserInfo : NSObject

@property HMChangeHenseiType type;

@property (strong) NSNumber *fleetNumber;
@property (strong) NSNumber *position;
@property (strong) NSNumber	*shipID;

@property (strong) NSNumber *replaceFleetNumber;
@property (strong) NSNumber *replacePosition;
@property (strong) NSNumber *replaceShipID;

@end


extern NSString *HMChangeHenseiNotification;
extern NSString *HMChangeHenseiUserInfoKey;
