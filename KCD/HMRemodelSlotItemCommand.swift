//
//  HMRemodelSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/22.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMRemodelSlotItemCommand: HMJSONCommand {
	override func execute() {
		let data = json[dataKey] as NSDictionary?
		if data == nil {
			NSLog("data is not dictionary")
			return
		}
		
		let success = data!["api_remodel_flag"] as NSNumber?
		if success == nil || !success!.boolValue {
			NSLog("Remodel is failed.")
			return
		}
		
		if let slotItemID = arguments["api_slot_id"] as? String {
			let store = HMServerDataStore.oneTimeEditor()
			let predicate = NSPredicate(format: "id = \(slotItemID)")
			var error: NSError? = nil
			let array = store.objectsWithEntityName("SlotItem",
				sortDescriptors: nil,
				predicate: predicate,
				error: &error)
			if array.count == 0 {
				NSLog("Could not find SlotItem number \(slotItemID)")
				if error != nil {
					NSLog("Fetch error: \(error!)")
				}
				return
			}
			
			if let item = array[0] as? HMKCSlotItemObject {
				if let afterSlot = data!["api_after_slot"] as? NSDictionary {
					if let locked = afterSlot["api_locked"] as? NSNumber {
						item.locked = locked
					}
					if let level = afterSlot["api_level"] as? NSNumber {
						item.level = level
					}
				}
				if let masterSoltItemID = data!["api_slotitem_id"] as? NSNumber {
					setMasterSlotItemForItemID(masterSoltItemID, item: item, store: store)
				}
			}
		}
	}
	
	func setMasterSlotItemForItemID(slotItemID: NSNumber, item: HMKCSlotItemObject, store: HMServerDataStore) {
		let predicate = NSPredicate(format: "id = \(slotItemID)")
		var error: NSError? = nil
		let array = store.objectsWithEntityName("MasterSlotItem",
			sortDescriptors: nil,
			predicate: predicate,
			error: &error)
		if array.count == 0 {
			NSLog("Could not find MasterSlotItem number \(slotItemID)")
			if error != nil {
				NSLog("Fetch error: \(error!)")
			}
			return
		}
		if let master = array[0] as? HMKCMasterSlotItemObject {
			item.master_slotItem = master
			item.slotitem_id = slotItemID
		}
	}
}
