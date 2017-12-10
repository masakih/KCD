//
//  ShipDeckCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ShipDeckCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .shipDeck
    }
    
    override func execute() {
        
        ShipMapper(apiResponse).commit()
        DeckMapper(apiResponse).commit()
        DummyShipCommand(apiResponse: apiResponse).execute()
        DropShipHistoryCommand(apiResponse: apiResponse).execute()
    }
}
