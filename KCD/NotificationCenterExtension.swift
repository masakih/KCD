//
//  NotificationCenterExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

extension NotificationCenter {
    
    func addObserverOnce(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) {
        
        weak var token: NSObjectProtocol?
        token = addObserver(forName: name, object: obj, queue: queue) { [weak self] notification in
            
            self.map { me in token.map(me.removeObserver) }
            block(notification)
        }
    }
}
