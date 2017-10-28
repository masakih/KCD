//
//  MapStartCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/18.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum MapAPI: String {
    
    case start = "/kcsapi/api_req_map/start"
    case next = "/kcsapi/api_req_map/next"
}

final class MapStartCommand: JSONCommand {
    
    private let store = TemporaryDataStore.oneTimeEditor()
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        return MapAPI(rawValue: api) != nil
    }
    
    override func execute() {
        
        MapAPI(rawValue: api).map {
            
            switch $0 {
            case .start: startBattle()
                
            case .next:
                nextCell()
                updateBattleCell()
            }
        }
        
        GuardShelterCommand(apiResponse: apiResponse).execute()
    }
    
    private func startBattle() {
        
        store.battles().forEach { store.delete($0) }
        
        guard let deckId = parameter["api_deck_id"].int,
            let mapArea = parameter["api_maparea_id"].int,
            let mapInfo = parameter["api_mapinfo_no"].int else {
                
                return Logger.shared.log("startBattle Arguments is wrong")
        }
        
        guard let no = data["api_no"].int else {
            
            return Logger.shared.log("startBattle JSON is wrong")
        }
        
        guard let battle = store.createBattle() else {
            
            return Logger.shared.log("Can not create Battle")
        }
        
        battle.deckId = deckId
        battle.mapArea = mapArea
        battle.mapInfo = mapInfo
        battle.no = no
    }
    
    private func nextCell() {
        
        guard let cellNumber = data["api_no"].int,
            let eventId = data["api_event_id"].int else {
                
                return Logger.shared.log("updateBattleCell JSON is wrong")
        }
        
        guard let battle = store.battle() else { return Logger.shared.log("Battle is invalid.") }
        
        battle.no = cellNumber
        battle.isBossCell = (eventId == 5)
    }
    
    private func updateBattleCell() {
        
        store.battle().map { $0.battleCell = nil }
    }
}
