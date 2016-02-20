//
//  HMFleetManager.h
//  KCD
//
//  Created by Hori,Masaki on 2016/02/14.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMFleet;
@interface HMFleetManager : NSObject

@property (readonly) NSArray<HMFleet *> *fleets;

@end
