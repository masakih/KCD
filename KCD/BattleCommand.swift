//
//  BattleCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/18.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class BattleCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.type == .battle || api.type == .battleResult
    }
    
    override func execute() {
        
        CalculateDamageCommand(apiResponse: apiResponse).execute()
        
        switch apiResponse.api.endpoint {
            
        case .battleResult, .combinedBattleResult:
            DropShipHistoryCommand(apiResponse: apiResponse).execute()
            DummyShipCommand(apiResponse: apiResponse).execute()
            GuardShelterCommand(apiResponse: apiResponse).execute()
            
        default:
            ()
        }
    }
}
