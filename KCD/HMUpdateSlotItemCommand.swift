//
//  HMUpdateSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/18.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMUpdateSlotItemCommand: HMJSONCommand {
	override var dataKey: String {
		return "api_data.api_slot_item"
	}
	
	override func execute() {
		if let data = json[dataKey] as? NSDictionary {
			if let slotItemID = data["api_slotitem_id"] as? NSNumber {
				if let itemID = data["api_id"] as? NSNumber {
					let store = HMServerDataStore.oneTimeEditor()
					let predicate = NSPredicate(format: "id = \(slotItemID)")
					var error: NSError? = nil
					let array = store.objectsWithEntityName("MasterSlotItem",
						sortDescriptors: nil,
						predicate: predicate,
						error: &error)
					if array.count == 0 {
						NSLog("MasterSlotItem is invalid")
						return
					}
					
					if let master = array[0] as? HMKCMasterSlotItemObject {
						let item = NSEntityDescription.insertNewObjectForEntityForName("SlotItem",
							inManagedObjectContext: store.managedObjectContext!) as HMKCSlotItemObject
						item.id = itemID
						item.master_slotItem = master
					}
				}
			}
		}
	}
}
