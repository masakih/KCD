//
//  RemodelSlotCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class RemodelSlotCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .remodelSlot
    }
    
    override func execute() {
        
        MaterialMapper(apiResponse).commit()
        RemodelSlotItemCommand(apiResponse: apiResponse).execute()
    }
}
