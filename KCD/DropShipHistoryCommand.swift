//
//  DropShipHistoryCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class DropShipHistoryCommand: JSONCommand {
    override func execute() {
        if api == "/kcsapi/api_port/port" || api == "/kcsapi/api_get_member/ship_deck" {
            storeToVisible()
        }
        if !api.hasSuffix("battleresult") { return }
        
        guard let shipName = data["api_get_ship"]["api_ship_name"].string,
            let winRank = data["api_win_rank"].string
            else { return }
        guard let battle = TemporaryDataStore.default.battle()
            else { return print("Can not get Battle") }
        let mapAreaId = battle.mapArea
        
        let store = ServerDataStore.default
        guard let mapInfo = store.mapInfo(area: mapAreaId, no: battle.mapInfo)
            else { return print("KCMasterMapInfo is not found") }
        guard let mapArea = store.mapArea(byId: mapAreaId)
            else { return print("KCMasterMapArea is not found") }
        
        let localStore = LocalDataStore.oneTimeEditor()
        guard let new = localStore.createHiddenDropShipHistory()
            else { return print("Can not create HiddenDropShipHistory") }
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
        store.hiddenDropShipHistories()
            .forEach {
                guard let new = store.createDropShipHistory()
                    else { return print("Can not create DropShipHistory") }
                new.shipName = $0.shipName
                new.mapArea = $0.mapArea
                new.mapAreaName = $0.mapAreaName
                new.mapInfo = $0.mapInfo
                new.mapInfoName = $0.mapInfoName
                new.mapCell = $0.mapCell
                new.winRank = $0.winRank
                new.date = $0.date
                
                store.delete($0)
        }
    }
}
