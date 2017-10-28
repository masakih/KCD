//
//  SetActionCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SetActionCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_air_corps/set_action" { return true }
        
        return false
    }
    
    override func execute() {
        
        guard let areaId = parameter["api_area_id"].int else {
            
            return Logger.shared.log("api_area_id is wrong.")
        }
        guard let rIds = parameter["api_base_id"]
            .string?
            .components(separatedBy: ",")
            .map({ Int($0) ?? -1 }) else {
                
                return Logger.shared.log("api_base_id is wrong.")
        }
        guard let actions = parameter["api_action_kind"]
            .string?
            .components(separatedBy: ",")
            .map({ Int($0) ?? -1 }) else {
                
                return Logger.shared.log("api_action_kind is rwong")
        }
        
        if rIds.count != actions.count { print("missmatch count") }
        
        let store = ServerDataStore.oneTimeEditor()
        
        zip(rIds, actions).forEach { (rId, action) in
            
            store.airBase(area: areaId, base: rId)?.action_kind = action
        }
    }
}
