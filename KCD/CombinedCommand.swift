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
let CombinedType = "com.masakih.KCD.Notification.CombinedDidCange.CombinedType"

class CombinedCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_hensei/combined" { return true }
        return false
    }
    
    override func execute() {
        if api == "/kcsapi/api_port/port" {
            guard let data = json["api_data"] as? [String: Any]
                else { return }
            if let t = data["api_combined_flag"] as? Int {
                CombineType(rawValue: t)
                    .map { postNotification(withType: $0) }
            }
            else { postNotification(withType: .cancel) }
            return
        }
        
        arguments["api_combined_type"]
            .flatMap { Int($0) }
            .flatMap { CombineType(rawValue:$0) }
            .map { postNotification(withType: $0) }
    }
    
    private func postNotification(withType type: CombineType) {
        let userInfo = [CombinedType:type]
        NotificationCenter
            .default
            .post(name: .CombinedDidCange, object: self, userInfo: userInfo)
    }
}
