//
//  MemberShip3Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberShip3Command: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .ship3
    }
    
    override func execute() {
        
        ShipMapper(apiResponse).commit()
        DeckMapper(apiResponse).commit()
    }
}
