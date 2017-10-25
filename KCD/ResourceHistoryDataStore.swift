//
//  ResourceHistoryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ResourceHistoryDataStore: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("ResourceHistory"))
    
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
