//
//  SlotResetCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SlotResetCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .exchangeIndex
    }
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync {
            
            guard let ship = self.parameter["api_id"].int.flatMap(store.ship(by:)) else {
                
                return Logger.shared.log("api_id is wrong")
            }
            guard let slotItems = self.data["api_slot"].arrayObject as? [Int] else {
                
                return Logger.shared.log("Can not parse api_data.api_slot")
            }
            
            zip(slotItems, 0...).forEach(ship.setItem)
            
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
}
