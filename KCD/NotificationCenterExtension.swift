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

extension NotificationCenter {
    
    /// Notificationを待って値が設定される Future<T>を返す
    ///
    /// - Parameters:
    ///   - name: Notification.Name
    ///   - object: 監視対象
    ///   - block:
    ///     Parameters: Notification
    ///     Returns: `T?` : 成功時は `T`, エラー時は例外を発生させる。 監視を継続するときは `nil`を返す
    /// - Returns: Notificationによって値が設定される Future<T>
    func future<T>(name: Notification.Name, object: Any?, block: @escaping (Notification) throws -> T?) -> Future<T> {
        
        let promise = Promise<T>()
        
        weak var token: NSObjectProtocol?
        token = self
            .addObserver(forName: name, object: object, queue: nil) { notification in
                
                do {
                    
                    guard let value = try block(notification) else {
                        
                        return
                    }
                    
                    promise.success(value)
                    
                } catch {
                    
                    promise.failure(error)
                }
                
                token.map(self.removeObserver)
        }
        
        return promise.future
    }
}
