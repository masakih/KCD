//
//  KaisouLockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class KaisouLockCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_kaisou/lock" { return true }
        
        return false
    }
    
    override func execute() {
        
        guard let slotId = parameter["api_slotitem_id"].int else {
            
            print("api_slotitem_id is wrong")
            return
        }
        guard let locked = data["api_locked"].int else {
            
            print("api_locked is wrong")
            return
        }
        
        let store = ServerDataStore.oneTimeEditor()
        
        store.slotItem(by: slotId)?.locked = locked != 0
    }
}
