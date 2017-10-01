//
//  IgnoreCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class IgnoreCommand: JSONCommand {
    
    private static let ignores: [String] = {
        
        guard let url = Bundle.main.url(forResource: "IgnoreCommand", withExtension: "plist"),
            let array = NSArray(contentsOf: url) as? [String] else {
                
                fatalError("Can not read IgnoreCommand.plist")
        }
        
        return array
    }()
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if ignores.contains(api) { return true }
        if api.hasPrefix("/kcsapi/api_req_ranking/") { return true }
        
        return false
    }
    
    override func execute() {
        
        // do nothing
    }
}
