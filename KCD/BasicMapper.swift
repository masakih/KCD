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

fileprivate func dataKey(_ apiResponse: APIResponse) -> String {
    guard let basicApi = BasicAPI(rawValue: apiResponse.api)
        else { return "api_data" }
    switch basicApi {
    case .port: return "api_data.api_basic"
    default: return "api_data"
    }
}

class BasicMapper: JSONMapper {
    let apiResponse: APIResponse
    let configuration: MappingConfiguration
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entityName: "Basic",
                                                  dataKey: dataKey(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    func commit() {
        let j = apiResponse.json as NSDictionary
        guard let data = j.value(forKeyPath: configuration.dataKey) as? [String: Any]
            else { return print("json is wrong") }
        
        let store = ServerDataStore.oneTimeEditor()
        guard let basic = store.basic() ?? store.createBasic()
            else { return print("Can not Get Basic") }
        registerElement(data, to: basic)
    }
}
