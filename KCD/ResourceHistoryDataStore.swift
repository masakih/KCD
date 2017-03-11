//
//  ResourceHistoryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataIntormation {
    static let resourceHistory = CoreDataIntormation(
        modelName: "ResourceHistory",
        storeFileName: "ResourceHistory.storedata",
        storeOptions:[NSMigratePersistentStoresAutomaticallyOption: true,
                      NSInferMappingModelAutomaticallyOption: true],
        storeType: NSSQLiteStoreType,
        deleteAndRetry: false
    )
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

extension KCResource: EntityProvider {
    override class var entityName: String { return "Resource" }
}

extension ResourceHistoryDataStore {
    func resources(in minites: [Int], older: Date) -> [KCResource] {
        let p = NSPredicate(format: "minute IN %@ AND date < %@", minites, older as NSDate)
        guard let resources = try? objects(with: KCResource.entity, predicate: p)
            else { return [] }
        return resources
    }
    func cerateResource() -> KCResource? {
        return insertNewObject(for: KCResource.entity)
    }
}
