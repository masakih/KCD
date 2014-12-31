//
//  HMKCSlotItemObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/31.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

extension HMKCSlotItemObject {
	var name: String? {
		willAccessValueForKey("master_slotItem")
		let name = master_slotItem.name
		didAccessValueForKey("master_slotItem")
		return name
	}
	var equippedShipName: String? {
		willAccessValueForKey("equippedShip")
		let name = equippedShip.name
		didAccessValueForKey("equippedShip")
		return name
	}
	var masterSlotItemRare: NSNumber? {
		willAccessValueForKey("master_slotItem")
		let rare = master_slotItem.rare
		didAccessValueForKey("master_slotItem")
		return rare
	}
	var typeName: NSNumber? {
		willAccessValueForKey("master_slotItem")
		let name = master_slotItem.type_2
		didAccessValueForKey("master_slotItem")
		return name
	}
	var isLocked: NSNumber? {
		willAccessValueForKey("locked")
		let locked = self.locked
		didAccessValueForKey("locked")
		return locked
	}
}
