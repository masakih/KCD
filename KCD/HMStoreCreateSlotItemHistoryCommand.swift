//
//  HMStoreCreateSlotItemHistoryCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/23.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMStoreCreateSlotItemHistoryCommand: HMJSONCommand {
	override func execute() {
		if let data = json[dataKey] as? NSDictionary {
			let store = HMServerDataStore.oneTimeEditor()
			var error: NSError? = nil
			
			var name = NSLocalizedString("fail to develop", comment: "")
			var numberOfUsedKaihatuSizai = 0
			var flagShipLv: NSNumber? = nil
			var flagShipName: String? = nil
			
			// name and numberOfUsedKaihatuSizai
			if let created = data["api_create_flag"] as? NSNumber {
				if created.boolValue {
					if let slotItemID = data["api_slot_item"]?["api_slotitem_id"] as? NSNumber {
						let predicate = NSPredicate(format: "id = \(slotItemID)")
						let array = store.objectsWithEntityName("MasterSlotItem",
							sortDescriptors: nil,
							predicate: predicate,
							error: &error)
						if array.count == 0 {
							NSLog("MasterSlotItem data is invalid or api_slotitem_id is invalid.")
							if error != nil {
								NSLog("Error: \(error!)")
							}
							return
						}
						if let master = array[0] as? HMKCMasterSlotItemObject {
							name = master.name
							numberOfUsedKaihatuSizai = 1
						}
					}
				}
			}
			
			// Deck -> FlagShip
			error = nil
			let predicate = NSPredicate(format: "id = 1")
			let decks = store.objectsWithEntityName("Deck",
				sortDescriptors: nil,
				predicate: predicate,
				error: &error)
			if decks.count == 0 {
				NSLog("Deck data is invalid.")
				if error != nil {
					NSLog("Error: \(error!)")
				}
				return
			}
			if let deck = decks[0] as? NSManagedObject {
				if let flagShipID = deck.valueForKey("ship_0") as? NSNumber {
					error = nil
					let shipPredicate = NSPredicate(format: "id = \(flagShipID)")
					let shipArray = store.objectsWithEntityName("Ship",
						sortDescriptors: nil,
						predicate: shipPredicate,
						error: &error)
					if shipArray.count == 0 {
						NSLog("Ship data is invalid or ship_0 is invalid.")
						if error != nil {
							NSLog("Error: \(error!)")
						}
						return
					}
					if let flagShip = shipArray[0] as? HMKCShipObject {
						flagShipLv = flagShip.lv
						flagShipName = flagShip.name
					}
				}
			}
			
			// Basic -> level
			error = nil
			let basicArray = store.objectsWithEntityName("Basic",
				sortDescriptors: nil,
				predicate: nil,
				error: &error)
			if basicArray.count == 0 {
				NSLog("Basic data is invalid.")
				if error != nil {
					NSLog("Error: \(error!)")
				}
				return
			}
			let commanderLv = basicArray[0].valueForKey("level") as NSNumber
			
			// create and insert KaihatuHistory
			let lds = HMLocalDataStore.oneTimeEditor()
			let newObject = NSEntityDescription.insertNewObjectForEntityForName("KaihatuHistory",
				inManagedObjectContext: lds.managedObjectContext!) as HMKaihatuHistory
			
			newObject.name = name
			newObject.kaihatusizai = numberOfUsedKaihatuSizai
			newObject.flagShipLv = flagShipLv!
			newObject.flagShipName = flagShipName!
			newObject.commanderLv = commanderLv
			newObject.date = NSDate(timeIntervalSinceNow: 0)
			if let fuel = arguments["api_item1"]?.integerValue {
				newObject.fuel = fuel
			}
			if let bull = arguments["api_item2"]?.integerValue {
				newObject.bull = bull
			}
			if let steel = arguments["api_item3"]?.integerValue {
				newObject.steel = steel
			}
			if let bauxite = arguments["api_item4"]?.integerValue {
				newObject.bauxite = bauxite
			}
			
			lds.saveAction(nil)
		}
	}
}
