//
//  NyukyoSpeedChangeCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class NyukyoSpeedChangeCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .speedChange
    }
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        let nDock = parameter["api_ndock_id"].int.flatMap(store.nyukyoDock(by:))
        
        nDock.flatMap { $0.ship_id }.flatMap(store.ship(by:)).map { $0.nowhp = $0.maxhp }
        nDock?.ship_id = 0
        nDock?.state = 0
        
        store.material().map { $0.kousokushuhuku = $0.kousokushuhuku - 1 }
    }
}
