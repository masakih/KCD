//
//  GetShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class GetShipCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .getShip
    }
    
    override func execute() {
        
        SlotItemMapper(apiResponse).commit()
        ShipMapper(apiResponse).commit()
        KenzoMarkCommand(apiResponse: apiResponse).execute()
        KenzoDockMapper(apiResponse).commit()
    }
}
