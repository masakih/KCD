//
//  HMDameameView.h
//  KCD
//
//  Created by Hori,Masaki on 2015/10/18.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, HMDamageType) {
	none = 0,
	slightly,
	modest,
	badly,
};

@interface HMDamageView : NSView

@property (nonatomic) HMDamageType damageType;

@end
