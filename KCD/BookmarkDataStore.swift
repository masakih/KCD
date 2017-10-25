//
//  BookmarkDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class BookmarkDataStore: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("Bookmark"))
    
    static let `default` = BookmarkDataStore(type: .reader)
    
    class func oneTimeEditor() -> BookmarkDataStore {
        
        return BookmarkDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        
        context = BookmarkDataStore.context(for: type)
    }
    
    deinit {
        
        save()
    }
    
    let context: NSManagedObjectContext
}
