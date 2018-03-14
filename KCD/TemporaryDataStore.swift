//
//  TemporaryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class TemporaryDataStore: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("Temporary",
                                                         fileName: ":memory:",
                                                         options: [:],
                                                         type: NSInMemoryStoreType))
    
    static let `default` = TemporaryDataStore(type: .reader)
    
    required init(type: CoreDataManagerType) {
        
        context = TemporaryDataStore.context(for: type)
    }
    
    deinit {
        
        save(errorHandler: presentOnMainThread)
    }
    
    let context: NSManagedObjectContext
}
