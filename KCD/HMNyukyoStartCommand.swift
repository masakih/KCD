//
//  HMNyukyoStartCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/17.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

/// 高速修復材を併用したときにHPを回復させる
class HMNyukyoStartCommand: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		// Mavericksにおいてload()のタイミングでNSArrayを生成することが出来ないため、遅延させる
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue()) {
			HMJSONCommand.registerInstance(self())
		}
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_req_nyukyo/start"
	}
	
	override func execute() {
		let obj = arguments["api_highspeed"] as String?
		if obj == nil { return }
		if let b = obj!.toInt() {
			if b == 0 { return }
		} else {
			return
		}
		
		if let shipID = arguments["api_ship_id"] as? String {
			var error: NSError? = nil
			let store = HMServerDataStore.oneTimeEditor()
			let predicate = NSPredicate(format: "id = \(shipID)")
			let array = store.objectsWithEntityName("Ship",
				sortDescriptors: nil,
				predicate: predicate,
				error: &error)
			if array.count == 0 {
				log("Could not find Ship id \(shipID)", argList: getVaList([]))
				return
			}
			
			if let ship = array[0] as? HMKCShipObject {
				ship.nowhp = ship.maxhp
			}
		}
	}
}
