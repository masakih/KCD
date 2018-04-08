//
//  AirCorpsSupplyCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class AirCorpsSupplyCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .airCorpsSupply
    }
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        store.async {
            
            guard let areaId = self.parameter["api_area_id"].int else {
                
                return
            }
            guard let rId = self.parameter["api_base_id"].int else {
                
                return
            }
            guard let airBase = store.airBase(area: areaId, base: rId) else {
                
                return
            }
            
            let planeInfos = self.data["api_plane_info"]
            let planes = airBase.planeInfo
            
            self.parameter["api_squadron_id"]
                .integerArray
                .enumerated()
                .forEach {
                    
                    guard planes.count >= $0.element else {
                        
                        return
                    }
                    guard planeInfos.count > $0.offset else {
                        
                        return
                    }
                    guard let plane = planes[$0.element - 1] as? AirBasePlaneInfo else {
                        
                        return
                    }
                    
                    let planeInfo = planeInfos[$0.offset]
                    
                    if let v = planeInfo["api_cond"].int {
                        
                        plane.cond = v
                    }
                    if let v = planeInfo["api_slotid"].int {
                        
                        plane.slotid = v
                    }
                    if let v = planeInfo["api_state"].int {
                        
                        plane.state = v
                    }
                    if let v = planeInfo["api_count"].int {
                        
                        plane.count = v
                    }
                    if let v = planeInfo["api_max_count"].int {
                        
                        plane.max_count = v
                    }
            }
            
            if let v = self.data["api_distance"].int {
                
                airBase.distance = v
            }
            
            guard let material = store.material() else {
                
                return
            }
            
            if let v = self.data["api_after_bauxite"].int {
                
                material.bauxite = v
            }
            if let v = self.data["api_after_fuel"].int {
                
                material.fuel = v
            }
        }
    }
}
