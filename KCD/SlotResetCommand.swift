//
//  SlotResetCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SlotResetCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_kaisou/slot_exchange_index" { return true }
        
        return false
    }
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let ship = parameter["api_id"]
            .int
            .flatMap({ store.ship(by: $0) })
            else { return print("api_id is wrong") }
        
        guard let slotItems = data["api_slot"].arrayObject as? [Int]
            else { return print("Can not parse api_data.api_slot") }
        
        slotItems.enumerated().forEach { ship.setItem($0.element, for: $0.offset) }
        
        let storedSlotItems = store.sortedSlotItemsById()
        let newSet = slotItems
            .flatMap { slotItem -> SlotItem? in
                
                guard slotItem > 0 else { return nil }
                
                let found = storedSlotItems.binarySearch { $0.id ==? slotItem }
                if let item = found { return item }
                print("Item \(slotItem) is not found")
                
                return nil
        }
        
        ship.equippedItem = NSOrderedSet(array: newSet)
    }
}
