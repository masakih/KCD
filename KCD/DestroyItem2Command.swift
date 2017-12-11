//
//  DestroyItem2Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DestroyItem2Command: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .destroyItem2
    }
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        store.slotItems(in: parameter["api_slotitem_ids"].integerArray).forEach(store.delete)
        
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
