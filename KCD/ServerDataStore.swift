//
//  ServerDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/07.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ServerDataStore: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("KCD", tryRemake: true))
    
    static let `default` = ServerDataStore(type: .reader)
    
    class func oneTimeEditor() -> ServerDataStore {
        
        return ServerDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        
        context = ServerDataStore.context(for: type)
    }
    
    deinit {
        
        save(errorHandler: presentOnMainThread)
    }
    
    let context: NSManagedObjectContext
}
