//
//  HokyuChargeCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class HokyuChargeCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .charge
    }
    
    override func execute() {
        
        MaterialMapper(apiResponse).commit()
        ApplySuppliesCommand(apiResponse: apiResponse).execute()
    }
}
