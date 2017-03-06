//
//  ShipDeckCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ShipDeckCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_get_member/ship_deck" { return true }
        return false
    }
    
    override func execute() {
        ShipMapper(apiResponse).commit()
        DeckMapper(apiResponse).commit()
        DummyShipCommand(apiResponse: apiResponse).execute()
        GuardShelterCommand(apiResponse: apiResponse).execute()
        DropShipHistoryCommand(apiResponse: apiResponse).execute()
    }
}
