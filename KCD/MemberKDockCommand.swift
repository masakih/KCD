//
//  MemberKDockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberKDockCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .kdock
    }
    
    override func execute() {
        
        KenzoDockMapper(apiResponse).commit()
    }
}
