//
//  GetShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class GetShipCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_kousyou/getship" { return true }
        
        return false
    }
    
    override func execute() {
        
        SlotItemMapper(apiResponse).commit()
        ShipMapper(apiResponse).commit()
        KenzoMarkCommand(apiResponse: apiResponse).execute()
        KenzoDockMapper(apiResponse).commit()
    }
}
