//
//  MasterMissionMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MasterMissionMapper: JSONMapper {
    typealias ObjectType = MasterMission

    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterMission.entity,
                                             dataKeys: ["api_data", "api_mst_mission"],
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }
}
