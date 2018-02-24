//
//  BasicMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class BasicMapper: JSONMapper {
        
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<Basic>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Basic.entity,
                                                  dataKeys: BasicMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        switch apiResponse.api.endpoint {
            
        case .port: return ["api_data", "api_basic"]
            
        case .basic: return ["api_data"]
            
        default: return Logger.shared.log("Missing API: \(apiResponse.api)", value: ["api_data"])
        }
    }
    
    func commit() {
        
        configuration.editorStore.async(execute: commintInContext)
    }
    private func commintInContext() {
        
        guard let store = configuration.editorStore as? ServerDataStore,
            let basic = store.basic() ?? store.createBasic() else {
                
                return Logger.shared.log("Can not Get Basic")
        }
        
        registerElement(data, to: basic)
    }
}
