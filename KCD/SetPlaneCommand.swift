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
        guard let distance = data["api_distance"].int,
            let bauxite = data["api_after_bauxite"].int
            else { return print("JSON is wrong") }
        let planInfo = data["api_plane_info"][0]
        guard let cond = planInfo["api_cond"].int,
            let slotid = planInfo["api_slotid"].int,
            let state = planInfo["api_state"].int,
            let count = planInfo["api_count"].int,
            let maxCount = planInfo["api_max_count"].int
            else { return print("api_plane_info is wrong") }
        
        let store = ServerDataStore.oneTimeEditor()
        guard let airbase = store.airBase(area: areaId, base: rId)
            else { return print("AirBase is not found") }
        let planes = airbase.planeInfo
        guard planes.count >= squadronId,
            let plane = planes[squadronId - 1] as? AirBasePlaneInfo
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
