//
//  ClearItemGetComand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ClearItemGetComand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_quest/clearitemget" { return true }
        
        return false
    }
    
    override func execute() {
        
        UpdateQuestListCommand(apiResponse: apiResponse).execute()
    }
}
