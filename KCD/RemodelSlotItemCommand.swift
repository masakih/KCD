//
//  RemodelSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class RemodelSlotItemCommand: JSONCommand {
    
    override func execute() {
        
        guard let success = data["api_remodel_flag"].int,
            success != 0
            else { return }
        
        guard let slotItemId = parameter["api_slot_id"].int
            else { return print("api_slot_id is wrong") }
        
        let afterSlot = data["api_after_slot"]
        let store = ServerDataStore.oneTimeEditor()
        
        guard let slotItem = store.slotItem(by: slotItemId)
            else { return print("SlotItem not found") }

        if let locked = afterSlot["api_locked"].int {
            
            slotItem.locked = locked != 0
            
        }
        if let masterSlotItemId = afterSlot["api_slotitem_id"].int,
            masterSlotItemId != slotItem.slotitem_id,
            let masterSlotItem = store.masterSlotItem(by: slotItemId) {
            
            slotItem.master_slotItem = masterSlotItem
            slotItem.slotitem_id = slotItemId
            
        }
        if let level = afterSlot["api_level"].int {
            
            slotItem.level = level
            
        }
        
        // remove used slot items.
        guard let useSlot = data["api_use_slot_id"].arrayObject as? [Int]
            else { return }
        
        store.slotItems(in: useSlot).forEach { store.delete($0) }
    }
}
