//
//  ResourceHistoryDataStoreAccessor.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Doutaku

extension ResourceHistoryDataStore {
    
    func resources(in minites: [Int], older: Date) -> [Resource] {
        
        let predicate = Predicate(\Resource.minute, in: minites)
            .and(Predicate(\Resource.date, lessThan: older))
        
        guard let resources = try? objects(of: Resource.entity, predicate: predicate) else {
            
            return []
        }
        
        return resources
    }
    
    func createResource() -> Resource? {
        
        return insertNewObject(for: Resource.entity)
    }
}
