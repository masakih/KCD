//
//  MemberBasicCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/13.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberBasicCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_get_member/basic" { return true }
        
        return false
    }
    
    override func execute() {
        
        BasicMapper(apiResponse).commit()
    }
}
