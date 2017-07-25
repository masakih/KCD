//
//  MemberShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/13.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberShipCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_get_member/ship" { return true }
        
        return false
    }
    
    override func execute() {
        
        ShipMapper(apiResponse).commit()
    }
}
