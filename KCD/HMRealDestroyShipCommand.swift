//
//  HMRealDestroyShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/18.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMRealDestroyShipCommand: HMJSONCommand {
	override func execute() {
		if let destroyedShipID = arguments["api_ship_id"] as? String {
			let store = HMServerDataStore.oneTimeEditor()
			var error: NSError? = nil
			let predicate = NSPredicate(format: "id = \(destroyedShipID)")
			let ships = store.objectsWithEntityName("Ship",
				sortDescriptors: nil,
				predicate: predicate,
				error: &error)
			if(ships.count == 0) { return }
			if let ship = ships[0] as? HMKCShipObject {
				store.managedObjectContext!.deleteObject(ship)
			}
		}
	}
}
