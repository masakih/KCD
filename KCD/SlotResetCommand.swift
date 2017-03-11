//
//  SlotResetCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class SlotResetCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_kaisou/slot_exchange_index" { return true }
        return false
    }
    
    override func execute() {
        let store = ServerDataStore.oneTimeEditor()
        guard let ship = arguments["api_id"]
            .flatMap({ Int($0) })
            .flatMap({ store.ship(byId: $0) })
            else { return print("api_id is wrong") }
        guard let sl = json["api_data"] as? [String: Any],
            let slotItems = sl["api_slot"] as? [Int]
            else { return print("Can not parse api_data.api_slot") }
        
        slotItems.enumerated().forEach {
            ship.setValue($0.element, forKey: "slot_\($0.offset)")
        }
        
        let storedSlotItems = store.sortedSlotItemsById()
        let newSet = slotItems
            .flatMap { (slotItem) -> SlotItem? in
                let found = storedSlotItems.binarySearch { $0.id ==? slotItem }
                if let item = found {
                    return item
                }
                print("Item \(slotItem) is not found")
                return nil
        }
        
        ship.equippedItem = NSOrderedSet(array: newSet)
    }
}
