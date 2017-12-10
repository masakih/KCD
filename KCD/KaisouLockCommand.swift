//
//  KaisouLockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class KaisouLockCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .shipLock
    }
    
    override func execute() {
        
        guard let slotId = parameter["api_slotitem_id"].int else {
            
            return Logger.shared.log("api_slotitem_id is wrong")
        }
        guard let locked = data["api_locked"].int else {
            
            return Logger.shared.log("api_locked is wrong")
        }
        
        let store = ServerDataStore.oneTimeEditor()
        
        store.slotItem(by: slotId)?.locked = (locked != 0)
    }
}
