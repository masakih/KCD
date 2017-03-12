//
//  MasterSTypeMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MasterSTypeMapper: JSONMapper {
    typealias ObjectType = MasterSType

    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterSType.entity,
                                             dataKey: "api_data.api_mst_stype",
                                             editorStore: ServerDataStore.oneTimeEditor(),
                                             ignoreKeys: ["api_equip_type"])
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }
}
