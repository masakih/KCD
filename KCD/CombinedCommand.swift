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
    
    func displayName() -> String {
        
        switch self {
            
        case .cancel: return LocalizedStrings.uncombined.string
            
        case .maneuver: return LocalizedStrings.maneuver.string
            
        case .water: return LocalizedStrings.water.string
            
        case .transportation: return LocalizedStrings.transportation.string
            
        }
    }
}

extension Notification.Name {
    
    static let CombinedDidCange = Notification.Name("com.masakih.KCD.Notification.CombinedDidCange")
}

final class CombinedCommand: JSONCommand {
    
    static let userInfoKey = "com.masakih.KCD.Notification.CombinedDidCange.CombinedType"
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .henseiCombined
    }
    
    override func execute() {
        
        if api.endpoint == .port {
            
            handlePort()
            
            return
        }
        
        parameter["api_combined_type"]
            .int
            .flatMap { CombineType(rawValue: $0) }
            .map(postNotification(withType:))
    }
    
    private func handlePort() {
        
        if let t = data["api_combined_flag"].int {
            
            CombineType(rawValue: t).map(postNotification(withType:))
            
        } else {
            
            postNotification(withType: .cancel)
        }
    }
    
    private func postNotification(withType type: CombineType) {
        
        let userInfo = [CombinedCommand.userInfoKey: type]
        
        NotificationCenter.default.post(name: .CombinedDidCange, object: self, userInfo: userInfo)
    }
}
