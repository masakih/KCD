//
//  Start2Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class Start2Command: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_start2" { return true }
        
        return false
    }
    
    override func execute() {
        
        MasterMapAreaMapper(apiResponse).commit()
        MasterMapInfoMapper(apiResponse).commit()
        MasterSTypeMapper(apiResponse).commit()
        MasterShipMapper(apiResponse).commit()
        MasterMissionMapper(apiResponse).commit()
        MasterFurnitureMapper(apiResponse).commit()
        MasterSlotItemEquipTypeMapper(apiResponse).commit()
        MasterSlotItemMapper(apiResponse).commit()
        MasterUseItemMapper(apiResponse).commit()
    }
}
