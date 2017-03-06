//
//  DestroyShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class DestroyShipCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_kousyou/destroyship" { return true }
        return false
    }
    
    override func execute() {
        MaterialMapper(apiResponse).commit()
        RealDestroyShipCommand(apiResponse: apiResponse).execute()
    }
}
