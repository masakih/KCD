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
        
        guard let battle = TemporaryDataStore.default.battle() else {
            
            return Logger.shared.log("Can not get Battle")
        }
        
        let mapAreaId = battle.mapArea
        
        let store = ServerDataStore.default
        
        guard let mapInfo = store.mapInfo(area: mapAreaId, no: battle.mapInfo) else {
            
            return Logger.shared.log("KCMasterMapInfo is not found")
        }
        
        guard let mapArea = store.mapArea(by: mapAreaId) else {
            
            return Logger.shared.log("KCMasterMapArea is not found")
        }
        
        
        let localStore = LocalDataStore.oneTimeEditor()
        guard let new = localStore.createHiddenDropShipHistory() else {
            
            return Logger.shared.log("Can not create HiddenDropShipHistory")
        }
        
        new.shipName = shipName
        new.mapArea = "\(mapAreaId)"
        new.mapAreaName = mapArea.name
        new.mapInfo = battle.mapInfo
        new.mapInfoName = mapInfo.name
        new.mapCell = battle.no
        new.winRank = winRank
        new.date = Date()
    }
    
    private func storeToVisible() {
        
        let store = LocalDataStore.oneTimeEditor()
        
        let hidden = store.hiddenDropShipHistories()
        _ = hidden.map(store.createDropShipHistory(from:))
        hidden.forEach(store.delete)
    }
}
