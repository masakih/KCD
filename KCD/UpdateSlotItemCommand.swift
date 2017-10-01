//
//  UpdateSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class UpdateSlotItemCommand: JSONCommand {
    
    override func execute() {
        
        let data = json["api_data"]["api_slot_item"]
        
        guard let slotItemId = data["api_slotitem_id"].int else { return }
        
        guard let newSlotItemId = data["api_id"].int else {
            
            print("api_id is wrong")
            return
        }
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let masterSlotItem = store.masterSlotItem(by: slotItemId) else {
            
            print("MasterSlotItem is not found")
            return
        }
        
        guard let new = store.createSlotItem() else {
            
            print("Can not create new SlotItem")
            return
        }
        
        new.id = newSlotItemId
        new.master_slotItem = masterSlotItem
    }
}
