//
//  KenzoMarkCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class KenzoMarkCommand: JSONCommand {
    
    struct KenzoDockInfo {
        let dockId: Int
        let shipId: Int
        let fuel: Int
        let bull: Int
        let steel: Int
        let bauxite: Int
        let kaihatusizai: Int
    }
    
    override func execute() {
        
        let store = LocalDataStore.oneTimeEditor()
        store.sync {
            self.executeInContext(localStore: store)
        }
    }
    
    private func executeInContext(localStore: LocalDataStore) {
        
        guard let kdockId = parameter["api_kdock_id"].int else {
            
            return Logger.shared.log("api_kdock_id is wrong")
        }
        
        let store = ServerDataStore.default
        guard let kenzoDock = store.sync(execute: { store.kenzoDock(by: kdockId) }) else {
            
            return Logger.shared.log("KenzoDock is not found")
        }
        let kenzoDockInfo = store.sync {
            KenzoDockInfo(dockId: kenzoDock.id,
                          shipId: kenzoDock.created_ship_id,
                          fuel: kenzoDock.item1,
                          bull: kenzoDock.item2,
                          steel: kenzoDock.item3,
                          bauxite: kenzoDock.item4,
                          kaihatusizai: kenzoDock.item5)
        }
        guard let flagShip = store.sync(execute: { store.masterShip(by: kenzoDock.created_ship_id) }) else {
            
            return Logger.shared.log("MasterShip is not found")
        }
        
        guard let new = localStore.createKenzoHistory() else {
            
            return Logger.shared.log("Can not create KenzoHistory")
        }
        
        new.name = store.sync { flagShip.name }
        new.sTypeId = store.sync { flagShip.stype.id }
        new.fuel = kenzoDockInfo.fuel
        new.bull = kenzoDockInfo.bull
        new.steel = kenzoDockInfo.steel
        new.bauxite = kenzoDockInfo.bauxite
        new.kaihatusizai = kenzoDockInfo.kaihatusizai
        new.date = Date()
        (new.flagShipLv, new.flagShipName, new.commanderLv) = markedValues(docInfo: kenzoDockInfo, in: localStore)
    }
    
    private func markedValues(docInfo: KenzoDockInfo, in store: LocalDataStore) -> (Int, String, Int) {
        
        if let kenzoMark = store.kenzoMark(docInfo: docInfo) {
            
            return (kenzoMark.flagShipLv, kenzoMark.flagShipName, kenzoMark.commanderLv)
        }
        
        return (-1, "", -1)
    }
}
