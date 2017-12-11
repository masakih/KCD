//
//  RealPowerUpCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class RealPowerUpCommand: JSONCommand {
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        parameter["api_id_items"]
            .integerArray
            .flatMap(store.ship(by:))
            .forEach(store.delete)
    }
}
