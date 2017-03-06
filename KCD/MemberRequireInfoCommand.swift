//
//  MemberRequireInfoCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MemberRequireInfoCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_get_member/require_info" { return true }
        return false
    }
    
    override func execute() {
        SlotItemMapper(apiResponse).commit()
        KenzoDockMapper(apiResponse).commit()
    }
}
