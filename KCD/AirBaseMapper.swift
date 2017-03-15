//
//  AirBaseMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class AirBaseMapper: JSONMapper {
    typealias ObjectType = AirBase
    
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: AirBase.entity,
                                             dataKey: "api_data.api_air_base",
                                             compositPrimaryKeys: ["area_id", "rid"],
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }

    func handleExtraValue(_ value: Any, forKey key: String, to airbase: AirBase) -> Bool {
        if key != "api_plane_info" { return false }
        
        if airbase.planeInfo.count == 0 {
            if let store = configuration.editorStore as? ServerDataStore {
                let new: [AirBasePlaneInfo] = (0..<4).flatMap {_ in
                    store.createAirBasePlaneInfo()
                }
                airbase.planeInfo = NSOrderedSet(array: new)
            }
        }
        
        guard let planeInfos = value as? [[String: Any]]
            else {
                print("value is wrong")
                return false
        }
        guard let infos = airbase.planeInfo.array as? [AirBasePlaneInfo]
            else {
                print("airbase is wrong")
                return false
        }
        zip(infos, planeInfos).forEach { (info, dict) in
            guard let slotid = dict["api_slotid"] as? Int,
                slotid != 0
                else { return }
            guard let cond = dict["api_cond"] as? Int,
                let count = dict["api_count"] as? Int,
                let maxCount = dict["api_max_count"] as? Int,
                let squadronid = dict["api_squadron_id"] as? Int,
                let state = dict["api_state"] as? Int
                else { return print("planeInfos is wrong") }
            info.cond = cond
            info.count = count
            info.max_count = maxCount
            info.slotid = slotid
            info.squadron_id = squadronid
            info.state = state
            info.airBase = airbase
        }
        return true
    }
}
