//
//  MapInfoCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MapInfoCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_get_member/mapinfo" { return true }
        
        return false
    }
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        store.airBases().forEach { store.delete($0) }
        store.save()
        
        AirBaseMapper(apiResponse).commit()
    }
}
