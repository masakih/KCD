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

class MapStartCommand: JSONCommand {
    private let store = TemporaryDataStore.oneTimeEditor()
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        return MapAPI(rawValue: api) != nil ? true : false
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
        
        guard let deckId = arguments["api_deck_id"].flatMap({ Int($0) }),
            let mapArea = arguments["api_maparea_id"].flatMap({ Int($0) }),
            let mapInfo = arguments["api_mapinfo_no"].flatMap({ Int($0) })
            else { return print("startBattle Arguments is wrong") }
        
        guard let data = json["api_data"] as? [String: Any],
            let no = data["api_no"] as? Int
            else { return print("startBattle JSON is wrong") }
        guard let battle = store.insertNewObject(forEntityName: "Battle") as? KCBattle
            else { return print("Can not create Battle") }
        battle.deckId = deckId
        battle.mapArea = mapArea
        battle.mapInfo = mapInfo
        battle.no = no
    }
    private func nextCell() {
        guard let data = json[dataKey] as? [String: Any],
            let cellNumber = data["api_no"] as? Int,
            let eventId = data["api_event_id"] as? Int
            else { return print("updateBattleCell JSON is wrong") }
        guard let battle = store.battle()
            else { return print("Battle is invalid.") }
        battle.no = cellNumber
        battle.isBossCell = (eventId == 5)
    }
    private func updateBattleCell() {
        store.battle().map { $0.battleCell = nil }
    }
}