//
//  AirBaseMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class AirBaseMapper: JSONMapper {
        
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: AirBase.entity,
                                             dataKeys: ["api_data", "api_air_base"],
                                             primaryKeys: ["area_id", "rid"],
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
    }

    func handleExtraValue(_ value: JSON, forKey key: String, to airbase: AirBase) -> Bool {
        
        if key != "api_plane_info" { return false }
        
        if airbase.planeInfo.count == 0 {
            
            if let store = configuration.editorStore as? ServerDataStore {
                
                let new: [AirBasePlaneInfo] = (0..<4).flatMap {_ in
                    
                    store.createAirBasePlaneInfo()
                    
                }
                
                airbase.planeInfo = NSOrderedSet(array: new)
            }
        }
        
        guard let planeInfos = value.array else {
            
            print("value is wrong")
            return false
        }
        
        guard let infos = airbase.planeInfo.array as? [AirBasePlaneInfo] else {
            
            print("airbase is wrong")
            return false
        }
        
        zip(infos, planeInfos).forEach { (info, dict) in
            
            guard let slotid = dict["api_slotid"].int, slotid != 0 else { return }
            guard let state = dict["api_state"].int else { return }
            guard let squadronid = dict["api_squadron_id"].int else { return }
            
            if state == 2 {
                
                info.cond = 0
                info.count = 0
                info.max_count = 0
                info.slotid = slotid
                info.squadron_id = squadronid
                info.state = state
                info.airBase = airbase
                
                return
            }

            guard let cond = dict["api_cond"].int else {
                
                print("api_cond is wrong.")
                return
            }
            guard let count = dict["api_count"].int else {
                
                print("api_cond is wrong.")
                return
            }
            guard let maxCount = dict["api_max_count"].int else {
                
                print("api_max_count is wrong")
                return
            }
            
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
