//
//  DestroyItem2Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DestroyItem2Command: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_kousyou/destroyitem2" { return true }
        
        return false
    }
    
    override func execute() {
        
        guard let itemIds = parameter["api_slotitem_ids"]
            .string?
            .components(separatedBy: ",")
            .flatMap({ Int($0) }) else {
                
                return Logger.shared.log("api_slotitem_ids is wrong")
        }
        
        let store = ServerDataStore.oneTimeEditor()
        
        store.slotItems(in: itemIds).forEach(store.delete)
        
        guard let material = store.material() else {
            
            return Logger.shared.log("Material is not found")
        }
        guard let gm = data["api_get_material"].arrayObject as? [Int] else {
            
            return Logger.shared.log("api_get_material is wrong")
        }
        
        let resouces = [#keyPath(Material.fuel), #keyPath(Material.bull), #keyPath(Material.steel), #keyPath(Material.bauxite)]
        
        zip(gm, resouces).forEach {
            
            if let current = material.value(forKey: $0.1) as? Int {
                
                material.setValue((current + $0.0) as NSNumber, forKey: $0.1)
            }
        }
        
    }
}
