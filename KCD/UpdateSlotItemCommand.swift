//
//  UpdateSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class UpdateSlotItemCommand: JSONCommand {
    override func execute() {
        guard let d = json["api_data"] as? [String: Any]
            else { return print("api_data is wrong") }
        guard let data = d["api_slot_item"] as? [String: Any],
            let slotItemId = data["api_slotitem_id"] as? Int
            else { return }
        guard let newSlotItemId = data["api_id"] as? Int
            else { return print("api_id is wrong") }
        let store = ServerDataStore.oneTimeEditor()
        guard let masterSlotItem = store.masterSlotItem(by: slotItemId)
            else { return print("MasterSlotItem is not found") }
        guard let new = store.createSlotItem()
            else { return print("Can not create new SlotItem") }
        new.id = newSlotItemId
        new.master_slotItem = masterSlotItem
    }
}
