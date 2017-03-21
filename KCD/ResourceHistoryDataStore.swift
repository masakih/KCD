//
//  ResourceHistoryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataConfiguration {
    static let resourceHistory = CoreDataConfiguration("ResourceHistory")
}
extension CoreDataCore {
    static let resourceHistory = CoreDataCore(.resourceHistory)
}

class ResourceHistoryDataStore: CoreDataAccessor, CoreDataManager {
    static var `default` = ResourceHistoryDataStore(type: .reader)
    class func oneTimeEditor() -> ResourceHistoryDataStore {
        return ResourceHistoryDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        context = (type == .reader ? core.parentContext : core.editorContext())
    }
    deinit {
        save()
    }
    
    let core = CoreDataCore.resourceHistory
    let context: NSManagedObjectContext
}

extension ResourceHistoryDataStore {
    func resources(in minites: [Int], older: Date) -> [Resource] {
        let p = NSPredicate(format: "minute IN %@ AND date < %@", minites, older as NSDate)
        guard let resources = try? objects(with: Resource.entity, predicate: p)
            else { return [] }
        return resources
    }
    func cerateResource() -> Resource? {
        return insertNewObject(for: Resource.entity)
    }
}
