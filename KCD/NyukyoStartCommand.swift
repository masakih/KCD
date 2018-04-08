//
//  NyukyoStartCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class NyukyoStartCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .startNyukyo
    }
    
    override func execute() {
        
        guard let hi = parameter["api_highspeed"].int, hi != 0 else {
            
            return
        }
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync {
            
            self.parameter["api_ship_id"]
                .int
                .flatMap(store.ship(by:))
                .map { $0.nowhp = $0.maxhp }
            
            store.material()
                .map { $0.kousokushuhuku = $0.kousokushuhuku - 1 }
        }
    }
}
