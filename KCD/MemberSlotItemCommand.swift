//
//  MemberSlotItemCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberSlotItemCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .slotItem
    }
    
    override func execute() {
        
        SlotItemMapper(apiResponse).commit()
    }
}
