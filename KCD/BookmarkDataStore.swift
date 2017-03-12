//
//  BookmarkDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataIntormation {
    static let bookmark = CoreDataIntormation("Bookmark")
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
        managedObjectContext =
            type == .reader ? core.parentManagedObjectContext
            : core.editorManagedObjectContext()
    }
    deinit {
        saveActionCore()
    }
    
    let core = CoreDataCore.bookmark
    var managedObjectContext: NSManagedObjectContext
}

extension BookmarkDataStore {
    func createBookmark() -> Bookmark? {
        return insertNewObject(for: Bookmark.entity)
    }
}
