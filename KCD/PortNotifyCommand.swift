//
//  PortNotifyCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension Notification.Name {
    
    static let PortAPIReceived = Notification.Name("com.masakih.KCD.Notification.PortAPIReceived")
}

final class PortNotifyCommand: JSONCommand {
    
    override func execute() {
        
        DispatchQueue.main.async {
            
            NotificationCenter.default.post(name: .PortAPIReceived, object: self)
        }
    }
}
