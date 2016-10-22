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

@property (nonatomic, strong) NSNumber *fleetNumber;
@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, strong) NSNumber *shipID;

@property (nonatomic, strong) NSNumber *replaceFleetNumber;
@property (nonatomic, strong) NSNumber *replacePosition;
@property (nonatomic, strong) NSNumber *replaceShipID;

@end


extern NSString *HMChangeHenseiNotification;
extern NSString *HMChangeHenseiUserInfoKey;
