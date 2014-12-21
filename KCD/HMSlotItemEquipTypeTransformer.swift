//
//  HMSlotItemEquipTypeTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa
import ObjectiveC


@objc
class HMSlotItemEquipTypeTransformer: NSValueTransformer
{
	override class func load() {
		NSValueTransformer.setValueTransformer(HMSlotItemEquipTypeTransformer(), forName: "HMSlotItemEquipTypeTransformer")
	}
	
	override class func transformedValueClass() -> AnyClass {
		return NSString.self
	}
	
	override class func allowsReverseTransformation() -> Bool { return false }
	
	override func transformedValue(value: AnyObject?) -> AnyObject? {
		let numValue = value as? NSNumber
		if numValue == nil {
			return nil
		}
		
		var store = HMServerDataStore.oneTimeEditor()
		var error : NSError? = nil
		var array = store.objectsWithEntityName("MasterSlotItemEquipType", predicate: NSPredicate(format: "id = %@", numValue!), error: &error)
		if let actualError = error {
			println("MasterSlotItemEquipType is invalid. error ->/(actualError)")
			return nil
		}
		if array.count == 0 {
			println("MasterSlotItemEquipType is invalid.")
			return nil
		}
		
		return array[0].valueForKey("name")
	}
	
}
