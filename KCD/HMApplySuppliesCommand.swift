//
//  HMApplySuppliesCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/16.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMApplySuppliesCommand: HMJSONCommand {
	override func execute() {
		if let data = json["api_data"] as? [NSObject : AnyObject] {
			if let shipInfos = data["api_ship"] as? [AnyObject] {
				let store = HMServerDataStore.oneTimeEditor()
				
				for shipInfo in shipInfos {
					if let shipID = shipInfo["api_id"] as? NSNumber {
						var error: NSError? = nil
						let array = store.objectsWithEntityName(
							"Ship",
							sortDescriptors: nil,
							predicate: NSPredicate(format: "id = \(shipID)"),
							error: &error)
						if array.count == 0 {
							if error != nil {
								NSLog("\(__FUNCTION__) error: \(error!)")
							}
							continue
						}
						
						if let ship = array[0] as? HMKCShipObject {
							if let bull = shipInfo["api_bull"] as? NSNumber {
								ship.bull = bull
							}
							if let fuel = shipInfo["api_fuel"] as? NSNumber {
								ship.fuel = fuel
							}
							if let onslot = shipInfo["api_onslot"] as? [NSNumber] {
								ship.onslot_0 = onslot[0]
								ship.onslot_1 = onslot[1]
								ship.onslot_2 = onslot[2]
								ship.onslot_3 = onslot[3]
								ship.onslot_4 = onslot[4]
							}
						}
					}
				}
			}
		}
	}
}
