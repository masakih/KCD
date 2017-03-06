//
//  RealDestroyShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class RealDestroyShipCommand: JSONCommand {
    override func execute() {
        let store = ServerDataStore.oneTimeEditor()
        arguments["api_ship_id"]
            .flatMap { Int($0) }
            .flatMap { store.ship(byId: $0) }
            .flatMap { store.delete($0) }
    }
}
