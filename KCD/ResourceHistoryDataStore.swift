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

final class ResourceHistoryDataStore: CoreDataAccessor, CoreDataManager {
    
    static let core = CoreDataCore(.resourceHistory)
    
    static let `default` = ResourceHistoryDataStore(type: .reader)
    
    class func oneTimeEditor() -> ResourceHistoryDataStore {
        
        return ResourceHistoryDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        
        context = ResourceHistoryDataStore.context(for: type)
    }
    
    deinit {
        
        save()
    }
    
    let context: NSManagedObjectContext
}

extension ResourceHistoryDataStore {
    
    func resources(in minites: [Int], older: Date) -> [Resource] {
        
        let p = NSPredicate.empty
            .and(NSPredicate(#keyPath(Resource.minute), valuesIn: minites))
            .and(NSPredicate(#keyPath(Resource.date), lessThan: older))
        
        guard let resources = try? objects(of: Resource.entity, predicate: p) else { return [] }
        
        return resources
    }
    
    func createResource() -> Resource? {
        
        return insertNewObject(for: Resource.entity)
    }
}
