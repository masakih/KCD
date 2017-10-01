//
//  DeckMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DeckMapper: JSONMapper {
    
    typealias ObjectType = Deck
    
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<Deck>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Deck.entity,
                                                  dataKeys: DeckMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    
    private enum DeckAPI: String {
        
        case getMemberDeck = "/kcsapi/api_get_member/deck"
        case port = "/kcsapi/api_port/port"
        case getMemberShip2 = "/kcsapi/api_get_member/ship2"
        case getMemberShip3 = "/kcsapi/api_get_member/ship3"
        case getMemberShipDeck = "/kcsapi/api_get_member/ship_deck"
        case getMemberDeckPort = "/kcsapi/api_get_member/deck_port"
        case henseiPresetSelect = "/kcsapi/api_req_hensei/preset_select"
        case kaisouPowerUp = "/kcsapi/api_req_kaisou/powerup"
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        guard let deckApi = DeckAPI(rawValue: apiResponse.api) else { return ["api_data"] }
        
        switch deckApi {
        case .port: return ["api_data", "api_deck_port"]
            
        case .getMemberShip2: return ["api_data_deck"]
            
        case .getMemberShip3: return ["api_data", "api_deck_data"]
            
        case .getMemberShipDeck: return ["api_data", "api_deck_data"]
            
        case .kaisouPowerUp: return ["api_data", "api_deck"]
            
        case .getMemberDeck, .getMemberDeckPort, .henseiPresetSelect: return ["api_data"]
        }
    }
}
