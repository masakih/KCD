//
//  MemberMaterialCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MemberMaterialCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_get_member/material" { return true }
        return false
    }
    
    override func execute() {
        MaterialMapper(apiResponse).commit()
    }
}
