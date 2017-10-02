//
//  MasterSlotItemMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MasterSlotItemMapper: JSONMapper {
    
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterSlotItem.entity,
                                             dataKeys: ["api_data", "api_mst_slotitem"],
                                             editorStore: ServerDataStore.oneTimeEditor(),
                                             ignoreKeys: ["api_version"])
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
    }
}
