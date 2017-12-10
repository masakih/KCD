//
//  NyukyoDockMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class NyukyoDockMapper: JSONMapper {
    
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<NyukyoDock>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: NyukyoDock.entity,
                                                  dataKeys: NyukyoDockMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        switch apiResponse.api.endpoint {
            
        case .port: return ["api_data", "api_ndock"]
            
        case .ndock: return ["api_data"]
            
        default: return Logger.shared.log("Missing API: \(apiResponse.api)", value: ["api_data"])
        }
    }
}
