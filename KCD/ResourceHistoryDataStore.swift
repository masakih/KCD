//
//  ResourceHistoryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataIntormation {
    static let resourceHistory = CoreDataIntormation("ResourceHistory")
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
        managedObjectContext =
            type == .reader ? core.parentManagedObjectContext
                : core.editorManagedObjectContext()
    }
    deinit {
        saveActionCore()
    }
    
    let core = CoreDataCore.resourceHistory
    var managedObjectContext: NSManagedObjectContext
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
