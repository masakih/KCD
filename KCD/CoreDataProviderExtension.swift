//
//  CoreDataProviderExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/21.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataProvider {
    
    /// 初回起動時などにデータがない時などにCoreDataを監視し値が設定される Future<T>を返す
    ///
    /// - Parameters:
    ///   - block:
    ///     Parameters: Notification (NSManagedObjectContextObjectsDidChange)
    ///     Returns: `T?` : 成功時は `T`, エラー時は例外を発生させる。 監視を継続するときは `nil`を返す
    /// - Returns: CoreDataの更新で値が設定される Future<T>
    func future<T>(block: @escaping (Notification) throws -> T?) -> Future<T> {
        
        return NotificationCenter.default
            .future(name: .NSManagedObjectContextObjectsDidChange, object: self.context, block: block)
    }
}
