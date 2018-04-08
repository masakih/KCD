//
//  ResourceHistoryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Doutaku

final class ResourceHistoryDataStore: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("ResourceHistory"))
    
    static let `default` = ResourceHistoryDataStore(type: .reader)
    
    required init(type: CoreDataManagerType) {
        
        context = ResourceHistoryDataStore.context(for: type)
    }
    
    deinit {
        
        save(errorHandler: presentOnMainThread)
    }
    
    let context: NSManagedObjectContext
}
