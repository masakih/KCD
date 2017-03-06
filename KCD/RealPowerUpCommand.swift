//
//  RealPowerUpCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class RealPowerUpCommand: JSONCommand {
    override func execute() {
        let store = ServerDataStore.oneTimeEditor()
        arguments["api_id_items"]?
            .components(separatedBy: ",")
            .flatMap { Int($0) }
            .flatMap { store.ship(byId: $0) }
            .forEach { store.delete($0) }
    }
}
