//
//  HMNyukyoSpeedChangeCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/20.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMNyukyoSpeedChangeCommand: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		HMJSONCommand.registerInstance(self())
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_req_nyukyo/speedchange"
	}
	
	override func execute() {
		if let ndockID = arguments["api_ndock_id"] as? String {
			let store = HMServerDataStore.oneTimeEditor()
			let predicate = NSPredicate(format: "id = \(ndockID)")
			var error: NSError? = nil
			let array = store.objectsWithEntityName("NyukyoDock",
				sortDescriptors: nil,
				predicate: predicate,
				error: &error)
			if array.count == 0 {
				if error != nil {
					log("error -> \(error!)", argList: getVaList([]))
				}
				return
			}
			
			if let dock = array[0] as? NSManagedObject {
				dock.setValue(nil, forKey: "ship_id")
				dock.setValue(NSNumber(long: 0), forKey: "state")
				
				// 艦隊リスト更新用
				if let shipID = dock.valueForKey("ship_id") as? String {
					let shipPredicate = NSPredicate(format: "id = \(shipID)")
					error = nil
					let shipArray = store.objectsWithEntityName("Ship",
						sortDescriptors: nil,
						predicate: shipPredicate,
						error: &error)
					if shipArray.count == 0 {
						if error != nil {
							log("error -> \(error!)", argList: getVaList([]))
						}
						return
					}
					if let ship = shipArray[0] as? HMKCShipObject {
						ship.nowhp = ship.maxhp
					}
				}
			}
		}
	}
}
