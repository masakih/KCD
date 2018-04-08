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
        
        guard let slotItemId = data["api_slotitem_id"].int else {
            
            return
        }
        
        guard let newSlotItemId = data["api_id"].int else {
            
            Logger.shared.log("api_id is wrong")
            
            return
        }
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let masterSlotItem = store.sync(execute: { store.masterSlotItem(by: slotItemId) }) else {
            
            Logger.shared.log("MasterSlotItem is not found")
            
            return
        }
        
        guard let new = store.sync(execute: { store.createSlotItem() }) else {
            
            Logger.shared.log("Can not create new SlotItem")
            
            return
        }
        
        store.sync {
            
            new.id = newSlotItemId
            new.master_slotItem = masterSlotItem
        }
    }
}
