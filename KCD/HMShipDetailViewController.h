//
//  HMShipDetailViewController.h
//  KCD
//
//  Created by Hori,Masaki on 2015/02/28.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMKCShipObject;


typedef NS_ENUM(NSInteger, HMShipDetailViewType) {
	full,
	medium,
	minimum,
};


@interface HMShipDetailViewController : NSViewController

- (instancetype)initWithType:(HMShipDetailViewType)type;
+ (instancetype)viewControllerWithType:(HMShipDetailViewType)type;

@property (strong) HMKCShipObject *ship;

@property (nonatomic) BOOL guardEscaped;

@end
