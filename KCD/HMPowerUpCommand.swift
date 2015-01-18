//
//  HMPowerUpCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/18.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMPowerUpCommand: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		// Mavericksにおいてload()のタイミングでNSArrayを生成することが出来ないため、遅延させる
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue()) {
			HMJSONCommand.registerInstance(self())
		}
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_req_kaisou/powerup"
	}
	
	override func execute() {
		if let usedShipsStrings = arguments["api_id_items"] as? String {
			let store = HMServerDataStore.oneTimeEditor()
			let moc = store.managedObjectContext!
			let shipsString = split(usedShipsStrings, { $0 == "," }, maxSplit: Int.max, allowEmptySlices: false)
			for shipID in shipsString {
				var error: NSError? = nil
				let predicate = NSPredicate(format: "id = \(shipID)")
				let array = store.objectsWithEntityName("Ship",
					sortDescriptors: nil,
					predicate: predicate,
					error: &error)
				if array.count == 0 {
					continue
				}
				
				if let ship = array[0] as? HMKCShipObject {
					moc.deleteObject(ship)
				}
			}
		}
	}
}
