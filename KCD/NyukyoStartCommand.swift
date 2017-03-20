//
//  NyukyoStartCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class NyukyoStartCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_nyukyo/start" { return true }
        return false
    }
    override func execute() {
        guard let hi = arguments["api_highspeed"].int,
            hi != 0
        else { return }
        
        let store = ServerDataStore.oneTimeEditor()
        arguments["api_ship_id"]
            .int
            .flatMap { store.ship(byId: $0) }
            .map { $0.nowhp = $0.maxhp }
        
        store.material()
            .map { $0.kousokushuhuku = $0.kousokushuhuku - 1 }
    }
}
