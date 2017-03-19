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
        let data = json["api_data"]["api_slot_item"]
        guard let slotItemId = data["api_slotitem_id"].int
            else { return }
        guard let newSlotItemId = data["api_id"].int
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
