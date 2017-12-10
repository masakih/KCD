//
//  ClearItemGetComand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ClearItemGetComand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .clearItemGet
    }
    
    override func execute() {
        
        UpdateQuestListCommand(apiResponse: apiResponse).execute()
    }
}
