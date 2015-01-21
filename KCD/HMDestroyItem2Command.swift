//
//  HMDestroyItem2Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/21.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa


extension String {
	var integerValue: Int { return toInt() ?? 0 }
}

class HMDestroyItem2Command: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		HMJSONCommand.registerInstance(self())
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_req_kousyou/destroyitem2"
	}
	
	override func execute() {
		let store = HMServerDataStore.oneTimeEditor()
		if let itemsString = arguments["api_slotitem_ids"] as? NSString {
			if let itemsStrings = itemsString.componentsSeparatedByString(",") as? [String] {
				var items: [AnyObject] = itemsStrings.map() {
					(item: String) in
					if let ID = item.toInt() {
						return NSNumber(long: ID)
					} else {
						return -1
					}
				}
				var error: NSError? = nil
				let predicate = NSPredicate(format: "id IN %@", argumentArray:[items])
				let array = store.objectsWithEntityName("SlotItem",
					sortDescriptors: nil,
					predicate: predicate,
					error: &error)
				if array.count == 0 {
					NSLog("SlotItem is invalid")
					if error != nil {
						NSLog("Error: \(error!)")
					}
					return
				}
				for i in array {
					store.managedObjectContext!.deleteObject(i as NSManagedObject)
				}
				
				error = nil
				let materials = store.objectsWithEntityName("Material",
					sortDescriptors: nil,
					predicate: nil,
					error: &error)
				if array.count == 0 {
					NSLog("SlotItem is invalid")
					if error != nil {
						NSLog("Error: \(error!)")
					}
					return
				}
				
				let material = materials[0] as NSManagedObject
				let keys = ["fuel", "bull", "steel", "bauxite", "kousokukenzo", "kousokushuhuku", "kaihatusizai", "screw"]
				if let growsMaterials = json.valueForKeyPath("api_data.api_get_material") as? [AnyObject] {
					for i in 0..<4 {
						let current = material.valueForKey(keys[i])?.integerValue
						let grows = growsMaterials[i].integerValue
						material.setValue(NSNumber(long: current! + grows), forKey:keys[i])
					}
				}
			}
		}
	}
}
