//
//  MaterialMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum MaterialAPI: String {
    case port = "/kcsapi/api_port/port"
    case kousyouCreateItem = "/kcsapi/api_req_kousyou/createitem"
    case kousyouDestoroyShip = "/kcsapi/api_req_kousyou/destroyship"
    case kousyouRemodelSlot = "/kcsapi/api_req_kousyou/remodel_slot"
    case hokyuCharge = "/kcsapi/api_req_hokyu/charge"
}

fileprivate func dataKey(_ apiResponse: APIResponse) -> String {
    guard let materialApi = MaterialAPI(rawValue: apiResponse.api)
        else { return "api_data" }
    switch materialApi {
    case .port: return "api_data.api_material"
    case .kousyouCreateItem: return "api_data.api_material"
    case .kousyouDestoroyShip: return "api_data.api_material"
    case .kousyouRemodelSlot: return "api_data.api_after_material"
    case .hokyuCharge: return "api_data.api_material"
    }
}

class MaterialMapper: JSONMapper {
    let apiResponse: APIResponse
    let configuration: MappingConfiguration
    
    private let keys = [
        "fuel", "bull", "steel", "bauxite",
        "kousokukenzo", "kousokushuhuku", "kaihatusizai", "screw"
    ]
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entityType: Material.self,
                                                  dataKey: dataKey(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    func commit() {
        let j = apiResponse.json as NSDictionary
        guard let data = j.value(forKeyPath: configuration.dataKey)
            else { return print("JSON is wrong") }
        guard let store = configuration.editorStore as? ServerDataStore,
            let material = store.material() ?? store.createMaterial()
            else { return print("Can not create Material") }
        
        switch data {
        case let array as [Int]: register(material, data: array)
        case let array as [[String: Any]]: register(material, data: array)
        default: print("JSON is unknown type")
        }
    }
    
    private func register(_ material: Material, data: [Int]) {
        data.enumerated().forEach {
            guard $0.offset < keys.count
                else { return }
            material.setValue($0.element as NSNumber, forKey: keys[$0.offset])
        }
    }
    private func register(_ material: Material, data: [[String: Any]]) {
        data.forEach {
            guard let i = $0["api_id"] as? Int,
                i != 0,
                i - 1 < keys.count,
                let newValue = $0["api_value"] as? Int
                else { return }
            material.setValue(newValue as NSNumber, forKey: keys[i - 1])
        }
    }
}
