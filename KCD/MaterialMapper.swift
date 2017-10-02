//
//  MaterialMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class MaterialMapper: JSONMapper {
        
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<Material>
    
    private let keys = [
        "fuel", "bull", "steel", "bauxite",
        "kousokukenzo", "kousokushuhuku", "kaihatusizai", "screw"
    ]
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Material.entity,
                                                  dataKeys: MaterialMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    
    private enum MaterialAPI: String {
        
        case port = "/kcsapi/api_port/port"
        case kousyouCreateItem = "/kcsapi/api_req_kousyou/createitem"
        case kousyouDestoroyShip = "/kcsapi/api_req_kousyou/destroyship"
        case kousyouRemodelSlot = "/kcsapi/api_req_kousyou/remodel_slot"
        case hokyuCharge = "/kcsapi/api_req_hokyu/charge"
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        guard let materialApi = MaterialAPI(rawValue: apiResponse.api) else { return ["api_data"] }
        
        switch materialApi {
        case .port: return ["api_data", "api_material"]
            
        case .kousyouCreateItem: return ["api_data", "api_material"]
            
        case .kousyouDestoroyShip: return ["api_data", "api_material"]
            
        case .kousyouRemodelSlot: return ["api_data", "api_after_material"]
            
        case .hokyuCharge: return ["api_data", "api_material"]
        }
    }
    
    func commit() {
        
        guard let store = configuration.editorStore as? ServerDataStore,
            let material = store.material() ?? store.createMaterial() else {
                
                print("Can not create Material")
                return
        }
        
        if let _ = data[0].int {
            
            let array = data.arrayValue.flatMap { $0.int }
            register(material, data: array)
            
        } else if let _ = data[0].dictionary {
            
            register(material, data: data.arrayValue)
            
        } else {
            
            print("JSON is unknown type")
            
        }
    }
    
    private func register(_ material: Material, data: [Int]) {
        
        data.enumerated().forEach {
            
            guard $0.offset < keys.count else { return }
            
            material.setValue($0.element as NSNumber, forKey: keys[$0.offset])
        }
    }
    
    private func register(_ material: Material, data: [JSON]) {
        
        data.forEach {
            
            guard let i = $0["api_id"].int, case 1..<keys.count = i else { return }
            guard let newValue = $0["api_value"].int else { return }
            
            material.setValue(newValue as NSNumber, forKey: keys[i - 1])
        }
    }
}
