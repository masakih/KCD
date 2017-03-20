//
//  KaisouLockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class KaisouLockCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_kaisou/lock" { return true }
        return false
    }
    
    override func execute() {
        guard let slotId = parameter["api_slotitem_id"].int
            else { return print("api_slotitem_id is wrong") }
        guard let locked = data["api_locked"].bool
            else { return print("api_locked is wrong") }
        let store = ServerDataStore.oneTimeEditor()
        store.slotItem(byId: slotId)?.locked = locked
    }
}
