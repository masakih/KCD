//
//  KenzoDockMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum KenzoDockAPI: String {
    
    case getMemberKDock = "/kcsapi/api_get_member/kdock"
    case kousyouGetShip = "/kcsapi/api_req_kousyou/getship"
    case getMemberRequireInfo = "/kcsapi/api_get_member/require_info"
}

fileprivate func dataKeys(_ apiResponse: APIResponse) -> [String] {
    
    guard let kenzoDockApi = KenzoDockAPI(rawValue: apiResponse.api)
        else { return ["api_data"] }
    
    switch kenzoDockApi {
    case .kousyouGetShip: return ["api_data", "api_kdock"]
        
    case .getMemberRequireInfo: return ["api_data", "api_kdock"]
        
    default: return ["api_data"]
    }
}

final class KenzoDockMapper: JSONMapper {
    
    typealias ObjectType = KenzoDock
    
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<KenzoDock>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: KenzoDock.entity,
                                                  dataKeys: dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
}
