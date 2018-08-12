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
        #keyPath(Material.fuel), #keyPath(Material.bull), #keyPath(Material.steel), #keyPath(Material.bauxite),
        #keyPath(Material.kousokukenzo), #keyPath(Material.kousokushuhuku), #keyPath(Material.kaihatusizai), #keyPath(Material.screw)
    ]
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Material.self,
                                                  dataKeys: MaterialMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
                
        switch apiResponse.api.endpoint {
            
        case .material: return ["api_data"]
            
        case .port, .createItem, .destroyShip, .charge: return ["api_data", "api_material"]
            
        case .remodelSlot: return ["api_data", "api_after_material"]
            
        default:
            
            Logger.shared.log("Missing API: \(apiResponse.api)")
            
            return ["api_data"]
        }
    }
    
    func commit() {
        
        configuration.editorStore.sync(execute: commintInContext)
    }
    
    private func commintInContext() {
        
        guard let store = configuration.editorStore as? ServerDataStore,
            let material = store.material() ?? store.createMaterial() else {
                
                Logger.shared.log("Can not create Material")
                
                return
        }
        
        if let _ = data[0].int {
            
            let array = data.arrayValue.compactMap { $0.int }
            register(material, data: array)
            
        } else if let _ = data[0].dictionary {
            
            register(material, data: data.arrayValue)
            
        } else {
            
            print("JSON is unknown type")
            
        }
    }
    
    private func register(_ material: Material, data: [Int]) {
        
        zip(data, keys).forEach {
            
            material.setValue($0, forKey: $1)
        }
    }
    
    private func register(_ material: Material, data: [JSON]) {
        
        data.forEach {
            
            guard let i = $0["api_id"].int, case 1...keys.count = i else {
                
                return
            }
            guard let newValue = $0["api_value"].int else {
                
                return
            }
            
            material.setValue(newValue as NSNumber, forKey: keys[i - 1])
        }
    }
}
