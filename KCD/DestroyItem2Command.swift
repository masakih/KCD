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
        
        store.sync { store.slotItems(in: self.parameter["api_slotitem_ids"].integerArray).forEach(store.delete) }
        
        guard let material = store.sync(execute: { store.material() }) else {
            
            Logger.shared.log("Material is not found")
            
            return
        }
        guard let getMaterials = data["api_get_material"].arrayObject as? [Int],
            getMaterials.count >= 4 else {
                
                Logger.shared.log("api_get_material is wrong")
                
                return
        }
        
        store.sync {
            
            material.fuel += getMaterials[0]
            material.bull += getMaterials[1]
            material.steel += getMaterials[2]
            material.bauxite += getMaterials[3]
        }
    }
}
