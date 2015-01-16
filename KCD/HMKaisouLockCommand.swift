//
//  HMKaisouLockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/16.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMKaisouLockCommand: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		// Mavericksにおいてload()のタイミングでNSArrayを生成することが出来ないため、遅延させる
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue()) {
			HMJSONCommand.registerInstance(self())
		}
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_req_kaisou/lock"
	}
	
	override func execute() {
		if let data = json[dataKey] as? NSDictionary {
			if let slotitemID = arguments["api_slotitem_id"] as? String {
				let store = HMServerDataStore.oneTimeEditor()
				var error: NSError? = nil
				let predicate = NSPredicate(format: "id = \(slotitemID)")
				let array = store.objectsWithEntityName("SlotItem",
					sortDescriptors: nil,
					predicate: predicate,
					error: &error)
				if error != nil {
					log("Feth error: \(error!)", argList: getVaList([]))
					return
				}
				if array.count == 0 {
					log("Could not find SlotItem number \(slotitemID)", argList: getVaList([]))
					return
				}
				if let locked = data["api_locked"] as? NSNumber {
					if let slotItem = array[0] as? HMKCSlotItemObject {
						slotItem.locked = locked.boolValue
					}
				}
			}
		} else {
			log("api_data is NOT NSDictionary", argList: getVaList([]))
		}
	}
}
