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
extension CoreDataCore {
    static let bookmark = CoreDataCore(.bookmark)
}

class BookmarkDataStore: CoreDataAccessor, CoreDataManager {
    static var `default` = BookmarkDataStore(type: .reader)
    class func oneTimeEditor() -> BookmarkDataStore {
        return BookmarkDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        context = (type == .reader ? core.parentContext : core.editorContext())
    }
    deinit {
        save()
    }
    
    let core = CoreDataCore.bookmark
    let context: NSManagedObjectContext
}

extension BookmarkDataStore {
    func createBookmark() -> Bookmark? {
        return insertNewObject(for: Bookmark.entity)
    }
}
