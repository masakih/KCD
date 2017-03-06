//
//  RemodelSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class RemodelSlotItemCommand: JSONCommand {
    override func execute() {
        guard let data = json[dataKey] as? [String: Any]
            else { return print("JSON is wrong") }
        
        guard let success = data["api_remodel_flag"] as? Int,
            success != 0
            else { return }
        
        guard let slotItemId = arguments["api_slot_id"].flatMap({ Int($0) }),
            let afterSlot = data["api_after_slot"] as? [String: Any]
            else { return print("api_slot_id is wrong") }
        
        let store = ServerDataStore.oneTimeEditor()
        guard let slotItem = store.slotItem(byId: slotItemId)
            else { return print("SlotItem not found") }

        if let locked = afterSlot["api_locked"] as? Bool {
            slotItem.locked = locked
        }
        if let masterSlotItemId = afterSlot["api_slotitem_id"] as? Int,
            masterSlotItemId != slotItem.slotitem_id,
            let masterSlotItem = store.masterSlotItem(by: slotItemId)
        {
            slotItem.master_slotItem = masterSlotItem
            slotItem.slotitem_id = slotItemId
        }
        if let level = afterSlot["api_level"] as? Int {
            slotItem.level = level
        }
        
        // remove used slot items.
        guard let useSlot = data["api_use_slot_id"] as? [Int]
            else { return }
        store.slotItems(in: useSlot).forEach { store.delete($0) }
    }
}
