//
//  NyukyoDockMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum DeckAPI: String {
    case getMemberNDock = "/kcsapi/api_get_member/ndock"
    case port = "/kcsapi/api_port/port"
}

fileprivate func dataKeys(_ apiResponse: APIResponse) -> [String] {
    guard let deckApi = DeckAPI(rawValue: apiResponse.api)
        else { return ["api_data"] }
    switch deckApi {
    case .port: return ["api_data", "api_ndock"]
    default: return ["api_data"]
    }
}

class NyukyoDockMapper: JSONMapper {
    typealias ObjectType = NyukyoDock

    let apiResponse: APIResponse
    let configuration: MappingConfiguration<NyukyoDock>
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: NyukyoDock.entity,
                                                  dataKeys: dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
}
