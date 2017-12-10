//
//  MemberRequireInfoCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberRequireInfoCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .requireInfo
    }
    
    override func execute() {
        
        SlotItemMapper(apiResponse).commit()
        KenzoDockMapper(apiResponse).commit()
    }
}
