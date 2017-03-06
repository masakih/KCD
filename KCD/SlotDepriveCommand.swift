//
//  SlotDepriveCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class SlotDepriveCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_kaisou/slot_deprive" { return true }
        return false
    }
    
    override func execute() {
        ShipMapper(apiResponse).commit()
    }
}
