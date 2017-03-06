//
//  MemberSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MemberSlotItemCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_get_member/slot_item" { return true }
        return false
    }
    
    override func execute() {
        SlotItemMapper(apiResponse).commit()
    }
}
