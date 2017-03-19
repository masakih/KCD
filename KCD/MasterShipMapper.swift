//
//  MasterShipMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

class MasterShipMapper: JSONMapper {
    typealias ObjectType = MasterShip
    
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entity: MasterShip.entity,
                                             dataKeys: ["api_data", "api_mst_ship"],
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }
    
    private lazy var masterSTypes: [MasterSType] = {
        return ServerDataStore.default.sortedMasterSTypesById()
    }()
    
    func handleExtraValue(_ value: JSON, forKey key: String, to masterShip: MasterShip) -> Bool {
        if key != "api_stype" { return false }
        
        guard let sType = value.int
            else {
                print("MasterShipMapper: value is not Int")
                return false
        }
        setStype(sType, to: masterShip)
        return true
    }
    
    private func setStype(_ stypeID: Int, to masterShip: MasterShip) {
        if masterShip.stype.id == stypeID { return }
        guard let stype = masterSTypes.binarySearch(comparator: { $0.id ==? stypeID })
            else { return print("MasterShipMapper: Can not find MasterSType") }
        guard let masterSType = configuration.editorStore.object(with: stype.objectID) as? MasterSType
            else { return print("MasterShipMapper: Can not convert to current moc object masterSType") }
        masterShip.stype = masterSType
    }
}
