//
//  CreateShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class CreateShipCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .createShip
    }
    
    override func execute() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.afterExecute()
        }
    }
    
    private func afterExecute() {
        
        guard let dockId = parameter["api_kdock_id"].int else {
            
            return Logger.shared.log("api_kdock_id is wrong")
        }
        
        let store = ServerDataStore.default
        
        let storedInfos: KenzoMarkCommand.KenzoDockInfo? = store.sync {
            
            guard let kenzoDock = store.kenzoDock(by: dockId)  else {
                    
                    return nil
            }
            
            return KenzoMarkCommand.KenzoDockInfo(dockId: kenzoDock.id,
                                                  shipId: kenzoDock.created_ship_id,
                                                  fuel: kenzoDock.item1,
                                                  bull: kenzoDock.item2,
                                                  steel: kenzoDock.item3,
                                                  bauxite: kenzoDock.item4,
                                                  kaihatusizai: kenzoDock.item5)
        }
        
        guard let infos = storedInfos else {
            
            return Logger.shared.log("Can not load KenzoDeck")
        }
        
        guard let flagShip = store.sync(execute: { store.deck(by: 1)?[0] }) else {
            
            return Logger.shared.log("Can not load deck")
        }
        guard let commanderLv = store.sync(execute: { store.basic()?.level }) else {
            
            return Logger.shared.log("Can not load basic")
        }
        
        let localStore = LocalDataStore.oneTimeEditor()
        localStore.sync {
            guard let newMark = localStore.kenzoMark(byDockId: dockId) ?? localStore.createKenzoMark() else {
                
                return Logger.shared.log("Can not create KenzoMark")
            }
            
            newMark.fuel = infos.fuel
            newMark.bull = infos.bull
            newMark.steel = infos.steel
            newMark.bauxite = infos.bauxite
            newMark.kaihatusizai = infos.kaihatusizai
            newMark.created_ship_id = infos.shipId
            newMark.flagShipName = store.sync { flagShip.name }
            newMark.flagShipLv = store.sync { flagShip.lv }
            newMark.commanderLv = commanderLv
            newMark.kDockId = dockId
        }
    }
}
