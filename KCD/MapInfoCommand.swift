//
//  MapInfoCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MapInfoCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .mapInfo
    }
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync {
            store.airBases().forEach(store.delete)
            store.save(errorHandler: store.presentOnMainThread)
        }
        
        AirBaseMapper(apiResponse).commit()
    }
}
