//
//  HMKCSlotItemObject+Extensions.m
//  KCD
//
//  Created by Hori,Masaki on 2014/10/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCSlotItemObject+Extensions.h"

#import "HMKCShipObject+Extensions.h"
#import "HMKCMasterSlotItemObject.h"

#import "HMServerDataStore.h"


@implementation HMKCSlotItemObject (Extensions)
- (NSString *)name
{
	[self willAccessValueForKey:@"master_slotItem"];
	NSString *name = [self.master_slotItem valueForKey:@"name"];
	[self didAccessValueForKey:@"master_slotItem"];
	return name;
}

- (NSString *)equippedShipName
{
	[self willAccessValueForKey:@"equippedShip"];
	NSString *equippedShipName = self.equippedShip.name;
	[self didAccessValueForKey:@"equippedShip"];
	return equippedShipName;
}
- (NSNumber *)equippedShipLv
{
	[self willAccessValueForKey:@"equippedShip"];
	NSNumber *equippedShipLv = self.equippedShip.lv;
	[self didAccessValueForKey:@"equippedShip"];
	return equippedShipLv;
}
- (NSNumber *)masterSlotItemRare
{
	[self willAccessValueForKey:@"master_slotItem"];
	NSNumber *masterSlotItemRare = [self.master_slotItem valueForKey:@"rare"];
	[self didAccessValueForKey:@"master_slotItem"];
	return masterSlotItemRare;
}
- (NSString *)typeName
{
	[self willAccessValueForKey:@"master_slotItem"];
	NSString *typeName = [self.master_slotItem valueForKey:@"type_2"];
	[self didAccessValueForKey:@"master_slotItem"];
	return typeName;
}
- (NSNumber *)isLocked
{
	[self willAccessValueForKey:@"locked"];
	NSNumber *locked = self.locked;
	[self didAccessValueForKey:@"locked"];
	return locked;
}
- (void)setIsLocked:(NSNumber *)isLocked {}

@end
