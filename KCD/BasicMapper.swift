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
    
    private enum BasicAPI: String {
        
        case getMemberBasic = "/kcsapi/api_get_member/basic"
        case port = "/kcsapi/api_port/port"
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        guard let basicApi = BasicAPI(rawValue: apiResponse.api) else { return ["api_data"] }
        
        switch basicApi {
        case .port: return ["api_data", "api_basic"]
            
        case .getMemberBasic: return ["api_data"]
        }
    }
    
    func commit() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let basic = store.basic() ?? store.createBasic() else {
            
            print("Can not Get Basic")
            return
        }
        
        registerElement(data, to: basic)
    }
}
