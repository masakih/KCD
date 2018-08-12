//
//  DeckMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DeckMapper: JSONMapper {
        
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<Deck>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Deck.self,
                                                  dataKeys: DeckMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor(),
                                                  ignoreKeys: ["api_flagship", "api_member_id", "api_name_id"])
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        switch apiResponse.api.endpoint {
            
        case .port: return ["api_data", "api_deck_port"]
            
        case .ship3, .shipDeck: return ["api_data", "api_deck_data"]
            
        case .ship2: return ["api_data_deck"]
            
        case .powerup: return ["api_data", "api_deck"]
            
        case .deck, .deckPort, .presetSelect: return ["api_data"]
            
        default:
            
            Logger.shared.log("Missing API: \(apiResponse.api)")
            
            return ["api_data"]
            
        }
    }
}
