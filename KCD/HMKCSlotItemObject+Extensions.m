//
//  HMKCSlotItemObject+Extensions.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCSlotItemObject+Extensions.h"

#import "HMKCShipObject+Extensions.h"

#import "HMServerDataStore.h"


@implementation HMKCSlotItemObject (Extensions)
- (NSString *)name
{
	return [self.master_slotItem valueForKey:@"name"];
}

- (NSString *)equippedShipName
{
	return self.equippedShip.name;
}
- (NSNumber *)masterSlotItemRare
{
	return [self.master_slotItem valueForKey:@"rare"];
}
- (NSString *)typeName
{
	return [self.master_slotItem valueForKey:@"type_2"];
}
- (NSNumber *)isLocked
{
	return self.locked;
}
- (void)setIsLocked:(NSNumber *)isLocked {}

@end
