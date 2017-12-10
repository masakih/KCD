//
//  AirCorpsChangeNameCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class AirCorpsChangeNameCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .airCorpsRename
    }
    
    override func execute() {
        
        guard let areaId = parameter["api_area_id"].int else { return }
        guard let rId = parameter["api_base_id"].int else { return }
        guard let name = parameter["api_name"].string else { return }
        
        let store = ServerDataStore.oneTimeEditor()
        
        store.airBase(area: areaId, base: rId)?.name = name
    }
}
