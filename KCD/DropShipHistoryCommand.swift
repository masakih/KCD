//
//  DropShipHistoryCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DropShipHistoryCommand: JSONCommand {
    
    override func execute() {
        
        if api.endpoint == .port || api.endpoint == .shipDeck {
            
            storeToVisible()
        }
        
        if api.type != .battleResult { return }
        
        guard let shipName = data["api_get_ship"]["api_ship_name"].string else { return }
        guard let winRank = data["api_win_rank"].string else { return }
        
        let tempStore = TemporaryDataStore.default
        guard let battle = tempStore.sync(execute: { tempStore.battle() }) else {
            
            return Logger.shared.log("Can not get Battle")
        }
        
        let mapAreaId = tempStore.sync { battle.mapArea }
        let mapInfoId = tempStore.sync { battle.mapInfo }
        
        let store = ServerDataStore.default
        
        guard let mapInfoName = store.sync(execute: { store.mapInfo(area: mapAreaId, no: mapInfoId)?.name }) else {
            
            return Logger.shared.log("KCMasterMapInfo is not found")
        }
        
        guard let mapAreaName = store.sync(execute: { store.mapArea(by: mapAreaId)?.name }) else {
            
            return Logger.shared.log("KCMasterMapArea is not found")
        }
        
        
        let localStore = LocalDataStore.oneTimeEditor()
        localStore.sync {
            
            guard let new = localStore.createHiddenDropShipHistory() else {
                
                return Logger.shared.log("Can not create HiddenDropShipHistory")
            }
            
            new.shipName = shipName
            new.mapArea = "\(mapAreaId)"
            new.mapAreaName = mapAreaName
            new.mapInfo = tempStore.sync { battle.mapInfo }
            new.mapInfoName = mapInfoName
            new.mapCell = tempStore.sync { battle.no }
            new.winRank = winRank
            new.date = Date()
        }
    }
    
    private func storeToVisible() {
        
        let store = LocalDataStore.oneTimeEditor()
        store.sync {
            let hidden = store.hiddenDropShipHistories()
            _ = hidden.map(store.createDropShipHistory(from:))
            hidden.forEach(store.delete)
        }
    }
}
