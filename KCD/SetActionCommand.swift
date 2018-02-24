//
//  SetActionCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SetActionCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .setAction
    }
    
    override func execute() {
        
        guard let areaId = parameter["api_area_id"].int else {
            
            return Logger.shared.log("api_area_id is wrong.")
        }
        
        let rIds = parameter["api_base_id"].integerArray
        let actions = parameter["api_action_kind"].integerArray
        if rIds.count != actions.count { print("missmatch count") }
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync {
            zip(rIds, actions).forEach { rId, action in
                
                store.airBase(area: areaId, base: rId)?.action_kind = action
            }
        }
    }
}
