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
        guard let areaId = arguments["api_area_id"].flatMap({ Int($0) }),
            let rId = arguments["api_base_id"].flatMap({ Int($0) }),
            let squadronIdsString = arguments["api_squadron_id"],
            let data = json[dataKey] as? [String: Any],
            let planeInfos = data["api_plane_info"] as? [[String: Any]],
            planeInfos.count != 0,
            let airBase = store.airBase(area: areaId, base: rId)
            else { return }
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
            
            if let v = planeInfo["api_cond"] as? Int { plane.cond = v }
            if let v = planeInfo["api_slotid"] as? Int { plane.slotid = v }
            if let v = planeInfo["api_state"] as? Int { plane.state = v }
            if let v = planeInfo["api_count"] as? Int { plane.count = v }
            if let v = planeInfo["api_max_count"] as? Int { plane.max_count = v }
        }
        if let v = data["api_distance"] as? Int { airBase.distance = v }
        
        guard let material = store.material()
            else { return }
        if let v = data["api_after_bauxite"] as? Int { material.bauxite = v }
        if let v = data["api_after_fuel"] as? Int { material.fuel = v }
    }
}
