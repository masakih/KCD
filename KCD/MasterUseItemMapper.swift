//
//  MasterUseItemMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MasterUseItemMapper: JSONMapper {
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entityType: MasterUseItem.self,
                                             dataKey: "api_data.api_mst_useitem",
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }
}
