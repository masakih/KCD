//
//  MasterShipMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class MasterShipMapper: JSONMapper {
        
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterShip.self,
                                             dataKeys: ["api_data", "api_mst_ship"],
                                             editorStore: ServerDataStore.oneTimeEditor(),
                                             ignoreKeys: ["api_sort_id"])
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
    }
    
    private lazy var masterSTypes: [MasterSType] = {
        
        guard let store = configuration.editorStore as? ServerDataStore else {
            
            return []
        }
        
        return store.sortedMasterSTypesById()
    }()
    
    func handleExtraValue(_ value: JSON, forKey key: String, to masterShip: MasterShip) -> Bool {
        
        if key != "api_stype" {
            
            return false
        }
        
        guard let sType = value.int else {
            
            Logger.shared.log("MasterShipMapper: value is not Int")
            
            return false
        }
        
        setStype(sType, to: masterShip)
        
        return true
    }
    
    private func setStype(_ stypeID: Int, to masterShip: MasterShip) {
        
        if masterShip.stype.id == stypeID { return }
        
        guard let stype = masterSTypes.binarySearch(comparator: { $0.id ==? stypeID }) else {
            
            Logger.shared.log("MasterShipMapper: Can not find MasterSType")
            
            return
        }
        
        // FUCK: 型推論がバカなのでダウンキャストしてるんだ！！！
        guard let masterSType = configuration.editorStore.exchange(stype) as? MasterSType else {
            
            Logger.shared.log("MasterShipMapper: Can not convert to current moc object masterSType")
            
            return
        }
        
        masterShip.stype = masterSType
    }
}
