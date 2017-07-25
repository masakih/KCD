//
//  BasicMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum BasicAPI: String {
    
    case getMemberBasic = "/kcsapi/api_get_member/basic"
    case port = "/kcsapi/api_port/port"
}

fileprivate func dataKeys(_ apiResponse: APIResponse) -> [String] {
    
    guard let basicApi = BasicAPI(rawValue: apiResponse.api)
        else { return ["api_data"] }
    
    switch basicApi {
    case .port: return ["api_data", "api_basic"]
        
    default: return ["api_data"]
    }
}

final class BasicMapper: JSONMapper {
    
    typealias ObjectType = Basic
    
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<Basic>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Basic.entity,
                                                  dataKeys: dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    func commit() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let basic = store.basic() ?? store.createBasic()
            else { return print("Can not Get Basic") }
        
        registerElement(data, to: basic)
    }
}
