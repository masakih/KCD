//
//  AirCorpsSupplyCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class AirCorpsSupplyCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_air_corps/supply" { return true }
        return false
    }
    
    override func execute() {
        let store = ServerDataStore.oneTimeEditor()
        guard let areaId = parameter["api_area_id"].int,
            let rId = parameter["api_base_id"].int,
            let squadronIdsString = parameter["api_squadron_id"].string,
            let airBase = store.airBase(area: areaId, base: rId)
            else { return }
        let planeInfos = data["api_plane_info"]
        let planes = airBase.planeInfo
        let squadronIds = squadronIdsString
            .components(separatedBy: ",")
            .flatMap { Int($0) }
        squadronIds.enumerated().forEach {
            guard planes.count >= $0.element,
                planeInfos.count > $0.offset,
                let plane = planes[$0.element - 1] as? AirBasePlaneInfo
                else { return }
            let planeInfo = planeInfos[$0.offset]
            
            if let v = planeInfo["api_cond"].int { plane.cond = v }
            if let v = planeInfo["api_slotid"].int { plane.slotid = v }
            if let v = planeInfo["api_state"].int { plane.state = v }
            if let v = planeInfo["api_count"].int { plane.count = v }
            if let v = planeInfo["api_max_count"].int { plane.max_count = v }
        }
        if let v = data["api_distance"].int { airBase.distance = v }
        
        guard let material = store.material()
            else { return }
        if let v = data["api_after_bauxite"].int { material.bauxite = v }
        if let v = data["api_after_fuel"].int { material.fuel = v }
    }
}
