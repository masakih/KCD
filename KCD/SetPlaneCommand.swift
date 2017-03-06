//
//  SetPlaneCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class SetPlaneCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_air_corps/set_plane" { return true }
        return false
    }
    
    override func execute() {
        guard let areaId = arguments["api_area_id"].flatMap({ Int($0) }),
            let rId = arguments["api_base_id"].flatMap({ Int($0) }),
            let squadronId = arguments["api_squadron_id"].flatMap({ Int($0) })
            else { return print("Argument is wrong") }
        guard let data = json[dataKey] as? [String: Any],
            let distance = data["api_distance"] as? Int,
            let bauxite = data["api_after_bauxite"] as? Int,
            let planInfos = data["api_plane_info"] as? [[String: Any]],
            let planInfo = planInfos.first
            else { return print("JSON is wrong") }
        guard let cond = planInfo["api_cond"] as? Int,
            let slotid = planInfo["api_slotid"] as? Int,
            let state = planInfo["api_state"] as? Int,
            let count = planInfo["api_count"] as? Int,
            let maxCount = planInfo["api_max_count"] as? Int
            else { return print("api_plane_info is wrong") }
        
        let store = ServerDataStore.oneTimeEditor()
        guard let airbase = store.airBase(area: areaId, base: rId)
            else { return print("AirBase is not found") }
        let planes = airbase.planeInfo
        guard planes.count >= squadronId,
            let plane = planes[squadronId - 1] as? KCAirBasePlaneInfo
            else { return print("AirBase is wrong") }
        plane.cond = cond
        plane.slotid = slotid
        plane.state = state
        plane.count = count
        plane.max_count = maxCount
        
        airbase.distance = distance
        
        store.material()?.bauxite = bauxite
    }
}
