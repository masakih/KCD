//
//  MasterFurnitureMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MasterFurnitureMapper: JSONMapper {
    
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterFurniture.self,
                                             dataKeys: ["api_data", "api_mst_furniture"],
                                             editorStore: ServerDataStore.oneTimeEditor(),
                                             ignoreKeys: ["api_season", "api_active_flag", "api_outside_id", "api_version"])
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
    }
}
