//
//  API.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/12/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//


import Foundation

enum Endpoint: String {
    
    case start2 = "/kcsapi/api_start2"
    case requireInfo = "/kcsapi/api_get_member/require_info"
    case mapInfo = "/kcsapi/api_get_member/mapinfo"
    
    // Port
    case port = "/kcsapi/api_port/port"
    
    // Dock
    case ndock = "/kcsapi/api_get_member/ndock"
    case kdock = "/kcsapi/api_get_member/kdock"
    
    // Deck
    case deck = "/kcsapi/api_get_member/deck"
    case deckPort = "/kcsapi/api_get_member/deck_port"
    case presetSelect = "/kcsapi/api_req_hensei/preset_select"
    
    // Supplies
    case material = "/kcsapi/api_get_member/material"
    case basic = "/kcsapi/api_get_member/basic"
    
    // Ship
    case ship = "/kcsapi/api_get_member/ship"
    case ship2 = "/kcsapi/api_get_member/ship2"
    case ship3 = "/kcsapi/api_get_member/ship3"
    case shipDeck = "/kcsapi/api_get_member/ship_deck"
    
    case createShip = "/kcsapi/api_req_kousyou/createship"
    case getShip = "/kcsapi/api_req_kousyou/getship"
    case destroyShip = "/kcsapi/api_req_kousyou/destroyship"
    
    case powerup = "/kcsapi/api_req_kaisou/powerup"
    
    case itemLock = "/kcsapi/api_req_kaisou/lock"
    
    // SlotItem
    case slotItem = "/kcsapi/api_get_member/slot_item"
    
    case exchangeIndex = "/kcsapi/api_req_kaisou/slot_exchange_index"
    case slotDeprive = "/kcsapi/api_req_kaisou/slot_deprive"
    
    case createItem = "/kcsapi/api_req_kousyou/createitem"
    case destroyItem2 = "/kcsapi/api_req_kousyou/destroyitem2"
    
    case remodelSlot = "/kcsapi/api_req_kousyou/remodel_slot"
    
    // Hensei
    case henseiCombined = "/kcsapi/api_req_hensei/combined"
    case change = "/kcsapi/api_req_hensei/change"
    
    // Nyukyo
    case startNyukyo = "/kcsapi/api_req_nyukyo/start"
    case speedChange = "/kcsapi/api_req_nyukyo/speedchange"
    
    // Charge
    case charge = "/kcsapi/api_req_hokyu/charge"
    
    // Airbase
    case setPlane = "/kcsapi/api_req_air_corps/set_plane"
    case setAction = "/kcsapi/api_req_air_corps/set_action"
    case airCorpsSupply = "/kcsapi/api_req_air_corps/supply"
    case airCorpsRename = "/kcsapi/api_req_air_corps/change_name"
    
    // Battle
    case battle = "/kcsapi/api_req_sortie/battle"
    
    case combinedBattle = "/kcsapi/api_req_combined_battle/battle"
    case combinedAirBattle = "/kcsapi/api_req_combined_battle/airbattle"
    case combinedBattleWater = "/kcsapi/api_req_combined_battle/battle_water"
    case combinedEcBattle = "/kcsapi/api_req_combined_battle/ec_battle"
    case combinedEachBattle = "/kcsapi/api_req_combined_battle/each_battle"
    case combinedEachBattleWater = "/kcsapi/api_req_combined_battle/each_battle_water"
    
    case combinedEachNightToDay = "/kcsapi/api_req_combined_battle/ec_night_to_day"
    
    case airBattle = "/kcsapi/api_req_sortie/airbattle"
    case ldAirBattle = "/kcsapi/api_req_sortie/ld_airbattle"
    case combinedLdAirBattle = "/kcsapi/api_req_combined_battle/ld_airbattle"
    
    case midnightBattle = "/kcsapi/api_req_battle_midnight/battle"
    case midnightSpMidnight = "/kcsapi/api_req_battle_midnight/sp_midnight"
    case combinedEcMidnightBattle = "/kcsapi/api_req_combined_battle/ec_midnight_battle"
    case combinedMidnightBattle = "/kcsapi/api_req_combined_battle/midnight_battle"
    case combinedSpMidnight = "/kcsapi/api_req_combined_battle/sp_midnight"
    
    case battleResult = "/kcsapi/api_req_sortie/battleresult"
    case combinedBattleResult = "/kcsapi/api_req_combined_battle/battleresult"
    
    // GuardEscape
    case goback = "/kcsapi/api_req_combined_battle/goback_port"
    case gobakAlone = "/kcsapi/api_req_sortie/goback_port"
    
    // Map
    case start = "/kcsapi/api_req_map/start"
    case next = "/kcsapi/api_req_map/next"
    
    //Quest
    case questList = "/kcsapi/api_get_member/questlist"
    case clearItemGet = "/kcsapi/api_req_quest/clearitemget"
    
    // Unknown
    case unknown = "UNKNOWN_API_STRING"
}

enum APIType {
    
    case port
    
    case deck
    
    case battle
    
    case battleResult
    
    case guardEscape
    
    case map
    
    case other
}

private func apiType(of endpoint: Endpoint) -> APIType {
    
    switch endpoint {
        
    case .port:
        
        return .port
        
    case .deck, .deckPort, .presetSelect:
        
        return .deck
        
    case .battle,
         .combinedBattle, .combinedAirBattle, .combinedBattleWater,
         .combinedEcBattle, .combinedEachBattle, .combinedEachBattleWater,
         .combinedEachNightToDay,
         .airBattle, .ldAirBattle, .combinedLdAirBattle,
         .midnightBattle, .midnightSpMidnight,
         .combinedMidnightBattle, .combinedEcMidnightBattle, .combinedSpMidnight:
        
        return .battle
        
    case .battleResult, .combinedBattleResult:
        
        return .battleResult
        
    case .goback, .gobakAlone:
        
        return .guardEscape
        
    case .start, .next:
        
        return .map
        
    default:
        
        return .other
        
    }
}

struct API {
    
    let endpoint: Endpoint
    
    var type: APIType {
        
        return apiType(of: endpoint)
    }
    
    private var endpointString: String {
        
        switch endpoint {
            
        case .unknown: return rawEndpointString ?? "Not Recorded"
            
        default: return endpoint.rawValue
            
        }
    }
    
    private var rawEndpointString: String?
    
    init(endpointPath rawValue: String) {
        
        endpoint = Endpoint(rawValue: rawValue) ?? .unknown
        
        if endpoint == .unknown {
            
            rawEndpointString = rawValue
        }
    }
    
    func includs(in rawValues: [String]) -> Bool {
        
        return rawValues.contains(endpointString)
    }
    
    func isRanking() -> Bool {
        
        return endpointString.hasPrefix("/kcsapi/api_req_ranking/")
    }
}

extension API: CustomStringConvertible {
    
    var description: String {
        
        return "API: \(endpointString)"
    }
}

extension API: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        return endpointString
    }
}
