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
	NSString *name = self.master_slotItem.name;
	return name;
}

- (NSString *)equippedShipName
{
	NSString *equippedShipName = self.equippedShip.name;
	
	if(!equippedShipName) {
		equippedShipName = self.extraEquippedShip.name;
	}
	return equippedShipName;
}
- (NSNumber *)equippedShipLv
{
	NSNumber *equippedShipLv = self.equippedShip.lv;
	
	if(!equippedShipLv) {
		equippedShipLv = self.extraEquippedShip.lv;
	}
	return equippedShipLv;
}
- (NSNumber *)masterSlotItemRare
{
	NSNumber *masterSlotItemRare = self.master_slotItem.rare;
	return masterSlotItemRare;
}
- (NSNumber *)typeName
{
	NSNumber *typeName = self.master_slotItem.type_2;
	return typeName;
}
- (NSNumber *)isLocked
{
	NSNumber *locked = self.locked;
	return locked;
}

@end
