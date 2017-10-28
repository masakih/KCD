//
//  LocalDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class LocalDataStore: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("LocalData"))
    
    static let `default` = LocalDataStore(type: .reader)
    
    class func oneTimeEditor() -> LocalDataStore {
        
        return LocalDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        
        context = LocalDataStore.context(for: type)
    }
    
    deinit {
        
        save(errorHandler: presentOnMainThread)
    }
    
    let context: NSManagedObjectContext
}
