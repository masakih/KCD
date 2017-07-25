//
//  MemberDeckCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberDeckCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_get_member/deck" { return true }
        if api == "/kcsapi/api_get_member/deck_port" { return true }
        if api == "/kcsapi/api_req_hensei/preset_select" { return true }
        
        return false
    }
    
    override func execute() {
        
        DeckMapper(apiResponse).commit()
    }
}
