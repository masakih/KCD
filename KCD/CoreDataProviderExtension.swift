//
//  CoreDataProviderExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/21.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Doutaku

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

extension Notification {
    
    struct ChangedType: OptionSet {
        
        let rawValue: UInt8
        
        static let inserted = ChangedType(rawValue: 0x0001)
        static let updated = ChangedType(rawValue: 0x0002)
        static let deleted = ChangedType(rawValue: 0x0004)
    }
    
    func insertedManagedObjects<T: NSManagedObject>() -> [T] {
        
        return managedObjects(infoKey: NSInsertedObjectsKey)
    }
    
    func updatedManagedObjects<T: NSManagedObject>() -> [T] {
        
        return managedObjects(infoKey: NSUpdatedObjectsKey)
    }
    
    func deletedManagedObjects<T: NSManagedObject>() -> [T] {
        
        return managedObjects(infoKey: NSDeletedObjectsKey)
    }
    
    func changedManagedObjects<T: NSManagedObject>(type: ChangedType) -> [T] {
        
        let inserted: [T] = type.contains(.inserted) ? insertedManagedObjects() : []
        let updated: [T] = type.contains(.updated) ? updatedManagedObjects() : []
        let deleted: [T] = type.contains(.deleted) ? deletedManagedObjects() : []
        
        return inserted + updated + deleted
    }
    
    private func managedObjects<T: NSManagedObject>(infoKey: String) -> [T] {
        
        guard let userInfo = self.userInfo as? [String: Any] else {
            
            return []
        }
        
        let inserted = userInfo[infoKey] as? Set<NSManagedObject>
        
        return inserted?.compactMap({ $0 as? T }) ?? []
    }
}
