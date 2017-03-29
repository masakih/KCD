//
//  NyukyoSpeedChangeCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class NyukyoSpeedChangeCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_nyukyo/speedchange" { return true }
        return false
    }
    override func execute() {
        let store = ServerDataStore.oneTimeEditor()
        let nDock = parameter["api_ndock_id"]
            .int
            .flatMap { store.nyukyoDock(by: $0) }
        nDock
            .flatMap { $0.ship_id }
            .flatMap { store.ship(by: $0) }
            .map { $0.nowhp = $0.maxhp }
        nDock?.ship_id = 0
        nDock?.state = 0
        
        store.material()
            .map { $0.kousokushuhuku = $0.kousokushuhuku - 1 }
    }
}
