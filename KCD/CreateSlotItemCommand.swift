//
//  CreateSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class CreateSlotItemCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_kousyou/createitem" { return true }
        return false
    }
    
    override func execute() {
        Thread.sleep(forTimeInterval: 6.5)
        MaterialMapper(apiResponse).commit()
        UpdateSlotItemCommand(apiResponse: apiResponse).execute()
        StoreCreateSlotItemHistoryCommand(apiResponse: apiResponse).execute()
    }
}
