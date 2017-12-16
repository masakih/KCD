//
//  KenzoMarkCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class KenzoMarkCommand: JSONCommand {
    
    override func execute() {
        
        guard let kdockId = parameter["api_kdock_id"].int else {
            
            return Logger.shared.log("api_kdock_id is wrong")
        }
        
        let store = ServerDataStore.default
        
        guard let kenzoDock = store.kenzoDock(by: kdockId) else {
            
            return Logger.shared.log("KenzoDock is not fount")
        }
                
        guard let flagShip = store.masterShip(by: kenzoDock.created_ship_id) else {
            
            return Logger.shared.log("MasterShip is not found")
        }
        
        let localStore = LocalDataStore.oneTimeEditor()
        guard let new = localStore.createKenzoHistory() else {
            
            return Logger.shared.log("Can not create KenzoHistory")
        }
        
        new.name = flagShip.name
        new.sTypeId = flagShip.stype.id
        new.fuel = kenzoDock.item1
        new.bull = kenzoDock.item2
        new.steel = kenzoDock.item3
        new.bauxite = kenzoDock.item4
        new.kaihatusizai = kenzoDock.item5
        new.date = Date()
        (new.flagShipLv, new.flagShipName, new.commanderLv) = markedValues(kenzoDock: kenzoDock, kdockId: kdockId)
    }
    
    private func markedValues(kenzoDock: KenzoDock, kdockId: Int) -> (Int, String, Int) {
        
        let store = LocalDataStore.default
        
        if let kenzoMark = store.kenzoMark(kenzoDock: kenzoDock,
                                           kDockId: kdockId) {
            
            return (kenzoMark.flagShipLv, kenzoMark.flagShipName, kenzoMark.commanderLv)
        }
        
        return (-1, "", -1)
    }
}
