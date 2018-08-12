//
//  MasterUseItemMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MasterUseItemMapper: JSONMapper {
    
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterUseItem.self,
                                             dataKeys: ["api_data", "api_mst_useitem"],
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
    }
}
