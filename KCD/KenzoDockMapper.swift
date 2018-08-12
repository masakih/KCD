//
//  KenzoDockMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class KenzoDockMapper: JSONMapper {
        
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<KenzoDock>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: KenzoDock.self,
                                                  dataKeys: KenzoDockMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor(),
                                                  ignoreKeys: ["api_member_id"])
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        switch apiResponse.api.endpoint {
            
        case .getShip, .requireInfo: return ["api_data", "api_kdock"]
                        
        case .kdock: return ["api_data"]
            
        default:
            
            Logger.shared.log("Missing API: \(apiResponse.api)")
            
            return ["api_data"]
        }
    }
}
