//
//  AirCorpsChangeNameCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class AirCorpsChangeNameCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_air_corps/change_name" { return true }
        return false
    }
    
    override func execute() {
        guard let areaId = arguments["api_area_id"].flatMap({ Int($0) }),
            let rId = arguments["api_base_id"].flatMap({ Int($0) }),
            let name = arguments["api_name"]
            else { return }
        let store = ServerDataStore.oneTimeEditor()
        store.airBase(area: areaId, base: rId)?.name = name
    }
}