//
//  HMAnchorageRepairManager.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/20.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAnchorageRepairManager.h"

#import "HMFleetManager.h"
#import "HMFleet.h"

#import "HMServerDataStore.h"
#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterShipObject.h"
#import "HMKCMasterSType.h"

#import "HMUserDefaults.h"

#import "HMChangeHenseiNotification.h"
#import "HMPortNotifyCommand.h"


@interface HMAnchorageRepairManager ()
@property (strong) HMFleetManager *fleetManager;

@property (strong) NSDate *repairTime;

@end

@implementation HMAnchorageRepairManager

+ (instancetype)defaultManager
{
	static HMAnchorageRepairManager *defaultManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultManager = [HMAnchorageRepairManager new];
	});
	return defaultManager;
}

- (instancetype)init
{
	self = [super init];
	if(self) {
		_fleetManager = [[[NSApplication sharedApplication] delegate] fleetManager];
		
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(henseiDidChangeNotification:)
													 name:HMChangeHenseiNotification
												   object:nil];
		[nc addObserver:self
			   selector:@selector(didReturnToBaseNotification:)
				   name:HMPortAPIRecieveNotification
				 object:nil];
	}
	
	return self;
}

- (NSDate *)repairTime
{
	return HMStandardDefaults.repairTime;;
}
- (void)setRepairTime:(NSDate *)repairTime
{
	HMStandardDefaults.repairTime = repairTime;
}

- (NSArray<NSNumber *> *)repairShipTypeIds
{
	return @[@(19)];
}

- (void)reset
{
	self.repairTime = [NSDate dateWithTimeIntervalSinceNow:0.0];
}

- (NSNumber *)shipTypeIDWithShipID:(NSNumber *)shipID
{
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSError *error = nil;
	NSArray<HMKCShipObject *> *array = [store objectsWithEntityName:@"Ship"
														  predicate:[NSPredicate predicateWithFormat:@"id = %@", shipID]
															  error:&error];
	if(array.count == 0) {
		NSLog(@"Ship not found.");
		return nil;
	}
	
	NSNumber *masterShipID = array[0].master_ship.stype.id;
	
	return masterShipID;
}

- (NSNumber *)shipTypeIDWithFleetNumber:(NSNumber *)fleetNumber position:(NSNumber *)position
{
	NSInteger fleetNumberValue = fleetNumber.integerValue;
	if(fleetNumberValue < 1 || fleetNumberValue > 4) return nil;
	
	HMFleet *fleet = self.fleetManager.fleets[fleetNumberValue - 1];
	HMKCShipObject *ship = fleet[position.integerValue];
	
	return ship.master_ship.stype.id;
}

- (BOOL)needsResetWithInfo:(HMChangeHenseiNotificationUserInfo *)userInfo
{
	// 変更のあった艦隊の旗艦は工作艦か？
	NSNumber *flagShipShipTypeID = [self shipTypeIDWithFleetNumber:userInfo.fleetNumber position:@0];
	if([self.repairShipTypeIds containsObject:flagShipShipTypeID]) {
		return YES;
	}
	if(userInfo.type == kHMChangeHenseiReplace) {
		flagShipShipTypeID = [self shipTypeIDWithFleetNumber:userInfo.replaceFleetNumber position:@0];
		if([self.repairShipTypeIds containsObject:flagShipShipTypeID]) {
			return YES;
		}
	}
	
	// 変更のあった艦娘は工作艦か？
	//     旗艦から外れたか？
	if(userInfo.type == kHMChangeHenseiRemove || userInfo.type == kHMChangeHenseiAppend) {
		NSNumber *shipTypeID = [self shipTypeIDWithShipID:userInfo.shipID];
		if([self.repairShipTypeIds containsObject:shipTypeID]) {
			return [userInfo.position isEqual:@0];
		}
	}
	if(userInfo.type == kHMChangeHenseiReplace) {
		NSNumber *shipTypeID = [self shipTypeIDWithShipID:userInfo.replaceShipID];
		if([self.repairShipTypeIds containsObject:shipTypeID]) {
			return [userInfo.replacePosition isEqual:@0];
		}
	}
	
	return NO;
}

- (void)didReturnToBaseNotification:(NSNotification *)notification
{
	// 時間をチェック
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSTimeInterval passedTime = [now timeIntervalSinceDate:self.repairTime];
	if(passedTime < 20 * 60) return;
	
	// 修理時間をリセット
	[self reset];
}

- (void)henseiDidChangeNotification:(NSNotification *)notification
{
	NSDictionary *userInfo = notification.userInfo;
	if(!userInfo) return;
	
	HMChangeHenseiNotificationUserInfo *info = userInfo[HMChangeHenseiUserInfoKey];
	
	switch(info.type) {
		case kHMChangeHenseiAppend:
		case kHMChangeHenseiReplace:
		case kHMChangeHenseiRemove:
			if([self needsResetWithInfo:info]) {
				[self reset];
			}
			break;
		case kHMChangeHenseiRemoveAllWithoutFlagship:
			// do nothing
			break;
		default:
			NSLog(@"Unknown hensei change type");
			break;
	}
}

@end
