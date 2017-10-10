//
//  CombinedCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum CombineType: Int {
    
    case cancel
    case maneuver
    case water
    case transportation
}

extension Notification.Name {
    
    static let CombinedDidCange = Notification.Name("com.masakih.KCD.Notification.CombinedDidCange")
}

final class CombinedCommand: JSONCommand {
    
    static let userInfoKey = "com.masakih.KCD.Notification.CombinedDidCange.CombinedType"
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        if api == "/kcsapi/api_req_hensei/combined" { return true }
        
        return false
    }
    
    override func execute() {
        
        if api == "/kcsapi/api_port/port" {
            
            if let t = data["api_combined_flag"].int {
                
                CombineType(rawValue: t).map(postNotification(withType:))
                
            } else {
                
                postNotification(withType: .cancel)
            }
            
            return
        }
        
        parameter["api_combined_type"]
            .int
            .flatMap { CombineType(rawValue: $0) }
            .map(postNotification(withType:))
    }
    
    private func postNotification(withType type: CombineType) {
        
        let userInfo = [CombinedCommand.userInfoKey: type]
        
        NotificationCenter.default.post(name: .CombinedDidCange, object: self, userInfo: userInfo)
    }
}
