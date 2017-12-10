//
//  MemberMaterialCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MemberMaterialCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .material
    }
    
    override func execute() {
        
        MaterialMapper(apiResponse).commit()
    }
}
