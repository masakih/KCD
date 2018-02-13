//
//  NotificationObserver.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/28.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

/// 開放時にremoveObserver(_:)を実行してくれるクラス
final class NotificationObserver {
    
    private var tokens: [NSObjectProtocol] = []
    
    func addObserver(forName name: Notification.Name, object: Any?, queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) {
        
        tokens += [NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: block)]
    }
    
    deinit {
        tokens.forEach(NotificationCenter.default.removeObserver)
    }
}
