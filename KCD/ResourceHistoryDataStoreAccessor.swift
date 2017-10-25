//
//  ResourceHistoryDataStoreAccessor.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

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
