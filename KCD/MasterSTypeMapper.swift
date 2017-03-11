//
//  MasterSTypeMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MasterSTypeMapper: JSONMapper {
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entityType: KCMasterSType.self,
                                             dataKey: "api_data.api_mst_stype",
                                             editorStore: ServerDataStore.oneTimeEditor(),
                                             ignoreKeys: ["api_equip_type"])
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }
}
