//
//  MasterShipMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MasterShipMapper: JSONMapper {
    let apiResponse: APIResponse
    let configuration = MappingConfiguration(entityName: "MasterShip",
                                             dataKey: "api_data.api_mst_ship",
                                             editorStore: ServerDataStore.oneTimeEditor())
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
    }
    
    private lazy var masterSTypes: [KCMasterSType] = {
        return ServerDataStore.default.sortedMasterSTypesById()
    }()
    
    func handleExtraValue(_ value: Any, forKey key: String, to object: NSManagedObject) -> Bool {
        if key != "api_stype" { return false }
        
        guard let sType = value as? Int
            else {
                print("MasterShipMapper: value is not Int")
                return false
        }
        guard let masterShip = object as? KCMasterShipObject
            else {
                print("MasterShipMapper: object is not KCMasterShipObject")
                return false
        }
        setStype(sType, to: masterShip)
        return true
    }
    
    private func setStype(_ stypeID: Int, to masterShip: KCMasterShipObject) {
        if masterShip.stype.id == stypeID { return }
        guard let stype = masterSTypes.binarySearch(comparator: { $0.id ==? stypeID })
            else { return print("MasterShipMapper: Can not find MasterSType") }
        guard let masterSType = configuration.editorStore.object(with: stype.objectID) as? KCMasterSType
            else { return print("MasterShipMapper: Can not convert to current moc object masterSType") }
        masterShip.stype = masterSType
    }
}
