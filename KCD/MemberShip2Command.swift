//
//  MemberShip2Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MemberShip2Command: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_get_member/ship2" { return true }
        return false
    }
    
    override func execute() {
        ShipMapper(apiResponse).commit()
        DeckMapper(apiResponse).commit()
    }
}
