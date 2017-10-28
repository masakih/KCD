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
        
        let fuel = kenzoDock.item1
        let bull = kenzoDock.item2
        let steel = kenzoDock.item3
        let bauxite = kenzoDock.item4
        let kaihatu = kenzoDock.item5
        let shipId = kenzoDock.created_ship_id
        
        guard let flagShip = store.masterShip(by: shipId) else {
            
            return Logger.shared.log("MasterShip is not found")
        }
        
        let localStore = LocalDataStore.oneTimeEditor()
        guard let new = localStore.createKenzoHistory() else {
            
            return Logger.shared.log("Can not create KenzoHistory")
        }
        
        new.name = flagShip.name
        new.sTypeId = flagShip.stype.id
        new.fuel = fuel
        new.bull = bull
        new.steel = steel
        new.bauxite = bauxite
        new.kaihatusizai = kaihatu
        new.date = Date()
        (new.flagShipLv, new.flagShipName, new.commanderLv) =
            markedValues(fuel: fuel,
                         bull: bull,
                         steel: steel,
                         bauxite: bauxite,
                         kaihatu: kaihatu,
                         kdockId: kdockId,
                         shipId: shipId)
    }
    
    // swiftlint:disable function_parameter_count
    private func markedValues(fuel: Int,
                              bull: Int,
                              steel: Int,
                              bauxite: Int,
                              kaihatu: Int,
                              kdockId: Int,
                              shipId: Int) -> (Int, String, Int) {
        
        let store = LocalDataStore.default
        
        if let kenzoMark = store.kenzoMark(fuel: fuel,
                                           bull: bull,
                                           steel: steel,
                                           bauxite: bauxite,
                                           kaihatusizai: kaihatu,
                                           kDockId: kdockId,
                                           shipId: shipId) {
            
            return (kenzoMark.flagShipLv, kenzoMark.flagShipName, kenzoMark.commanderLv)
        }
        
        return (-1, "", -1)
    }
}
