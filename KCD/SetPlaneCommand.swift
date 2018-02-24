//
//  SetPlaneCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SetPlaneCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .setPlane
    }
    
    override func execute() {
        
        guard let areaId = parameter["api_area_id"].int,
            let rId = parameter["api_base_id"].int,
            let squadronId = parameter["api_squadron_id"].int else {
                
                return Logger.shared.log("SetPlaneCommand: Argument is wrong")
        }
        guard let distance = data["api_distance"].int else {
            
            return Logger.shared.log("SetPlaneCommand: JSON is wrong")
        }
        
        let planInfo = data["api_plane_info"][0]
        
        guard let slotid = planInfo["api_slotid"].int,
            let state = planInfo["api_state"].int else {
                
                return Logger.shared.log("api_plane_info is wrong")
        }
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync {
            
            guard let airbase = store.airBase(area: areaId, base: rId) else {
                
                return Logger.shared.log("AirBase is not found")
            }
            
            let planes = airbase.planeInfo
            
            guard planes.count >= squadronId,
                let plane = planes[squadronId - 1] as? AirBasePlaneInfo else {
                    
                    return Logger.shared.log("AirBase is wrong")
            }
            
            // TODO: state が 2 の時のみ cond, count, max_count がnilであることを許すようにする
            plane.cond = planInfo["api_cond"].int ?? 0
            plane.slotid = slotid
            plane.state = state
            plane.count = planInfo["api_count"].int ?? 0
            plane.max_count = planInfo["api_max_count"].int ?? 0
            
            airbase.distance = distance
            
            self.data["api_after_bauxite"].int.map { store.material()?.bauxite = $0 }
        }
    }
}
