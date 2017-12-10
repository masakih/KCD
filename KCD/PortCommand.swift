//
//  PortCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class PortCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.type == .port
    }
    
    override func execute() {
        
        ShipMapper(apiResponse).commit()
        MaterialMapper(apiResponse).commit()
        DeckMapper(apiResponse).commit()
        BasicMapper(apiResponse).commit()
        NyukyoDockMapper(apiResponse).commit()
        
        ResetSortie().reset()
        
        DropShipHistoryCommand(apiResponse: apiResponse).execute()
        DummyShipCommand(apiResponse: apiResponse).execute()
        PortNotifyCommand(apiResponse: apiResponse).execute()
        GuardShelterCommand(apiResponse: apiResponse).execute()
        CombinedCommand(apiResponse: apiResponse).execute()
    }
}
