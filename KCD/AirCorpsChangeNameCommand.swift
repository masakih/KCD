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
        guard let areaId = parameter["api_area_id"].int,
            let rId = parameter["api_base_id"].int,
            let name = parameter["api_name"].string
            else { return }
        let store = ServerDataStore.oneTimeEditor()
        store.airBase(area: areaId, base: rId)?.name = name
    }
}
