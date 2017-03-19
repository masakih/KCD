//
//  MasterUseItemMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MasterUseItemMapper: JSONMapper {
    typealias ObjectType = MasterUseItem

    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterUseItem.entity,
                                             dataKeys: ["api_dat", "api_mst_useitem"],
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }
}
