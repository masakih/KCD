//
//  CreateSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class CreateSlotItemCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .createItem
    }
    
    override func execute() {
        
        Thread.sleep(forTimeInterval: 6.5)
        
        MaterialMapper(apiResponse).commit()
        UpdateSlotItemCommand(apiResponse: apiResponse).execute()
        StoreCreateSlotItemHistoryCommand(apiResponse: apiResponse).execute()
    }
}
