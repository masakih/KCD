//
//  HMKCDeck.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/31.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

extension HMKCDeck {
	private func shipOfShipNumber(shipNumber: Int) -> HMKCShipObject? {
		let key = "ship_\(shipNumber)"
		willAccessValueForKey(key)
		let shipID = valueForKey(key) as Int
		didAccessValueForKey(key)
		var array: [HMKCShipObject]? = nil
		if shipID == -1 { return nil }
		let request = NSFetchRequest(entityName: "Ship")
		request.predicate = NSPredicate(format: "id = %ld", argumentArray: [shipID])
		var error: NSError? = nil
		array = managedObjectContext?.executeFetchRequest(request, error: &error) as? [HMKCShipObject]
		if array == nil {
			println(__FUNCTION__, ": Could not found ship of id \(shipID)")
			if error != nil {
				println("\terror -> \(error!)")
			}
		}
		
		return array?[0]
	}
	
	var flagShip: HMKCShipObject? {
		return shipOfShipNumber(0)
	}
	var secondShip: HMKCShipObject? {
		return shipOfShipNumber(1)
	}
	var thirdShip: HMKCShipObject? {
		return shipOfShipNumber(2)
	}
	var fourthShip: HMKCShipObject? {
		return shipOfShipNumber(3)
	}
	var fifthShip: HMKCShipObject? {
		return shipOfShipNumber(4)
	}
	var sixthShip: HMKCShipObject? {
		return shipOfShipNumber(5)
	}
}
