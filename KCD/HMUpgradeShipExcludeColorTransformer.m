//
//  HMUpgradeShipExcludeColorTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2015/12/12.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMUpgradeShipExcludeColorTransformer.h"

#import "HMUpgradableShipsWindowController.h"


@implementation HMUpgradeShipExcludeColorTransformer
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSValueTransformer setValueTransformer:[self new] forName:@"HMUpgradeShipExcludeColorTransformer"];
	});
}
+ (Class)transformedValueClass
{
	return [NSColor class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	if(isExcludeShipID(value)) {
		return [NSColor lightGrayColor];
	}
	return [NSColor controlTextColor];
}
@end
