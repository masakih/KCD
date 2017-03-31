//
//  BookmarkDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataConfiguration {
    static let bookmark = CoreDataConfiguration("Bookmark")
}

class BookmarkDataStore: CoreDataAccessor, CoreDataManager {
    static let core = CoreDataCore(.bookmark)
    
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

extension BookmarkDataStore {
    func createBookmark() -> Bookmark? {
        return insertNewObject(for: Bookmark.entity)
    }
}
