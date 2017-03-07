//
//  MemberKDockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MemberKDockCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_get_member/kdock" { return true }
        return false
    }
    
    override func execute() {
        KenzoDockMapper(apiResponse).commit()
    }
}