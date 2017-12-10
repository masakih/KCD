//
//  MemberShip2Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberShip2Command: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .ship2
    }
    
    override func execute() {
        
        ShipMapper(apiResponse).commit()
        DeckMapper(apiResponse).commit()
    }
}
