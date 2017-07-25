//
//  MasterMapAreaMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MasterMapAreaMapper: JSONMapper {
    
    typealias ObjectType = MasterMapArea
    
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterMapArea.entity,
                                             dataKeys: ["api_data", "api_mst_maparea"],
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
    }
}
