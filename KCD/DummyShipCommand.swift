//
//  DummyShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/15.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

/**
 * 出撃中にドロップした艦をマスクした上で入居数に反映させるためのダミーデータの生成と削除を行う
 **/
final class DummyShipCommand: JSONCommand {
    
    private static var needsEnterDummy = false
    
    override func execute() {
        
        switch api.endpoint {
            
        case .battleResult, .combinedBattleResult: checkGetShip()
        
        case .shipDeck: enterDummy()
        
        case .port: removeDummy()
        
        default: return Logger.shared.log("Missing API: \(apiResponse.api)")
        }
    }
    
    private func checkGetShip() {
        
        DummyShipCommand.needsEnterDummy = data["api_get_ship"].exists()
    }
    
    private func enterDummy() {
        
        guard DummyShipCommand.needsEnterDummy else { return }
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync { store.createShip()?.id = -2 }
        DummyShipCommand.needsEnterDummy = false
    }
    
    private func removeDummy() {
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync { store.ships(by: -2).forEach(store.delete) }
        DummyShipCommand.needsEnterDummy = false
    }
}
