//
//  PowerUpCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class PowerUpCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_kaisou/powerup" { return true }
        
        return false
    }
    
    override func execute() {
        
        ShipMapper(apiResponse).commit()
        DeckMapper(apiResponse).commit()
        RealPowerUpCommand(apiResponse: apiResponse).execute()
    }
}
