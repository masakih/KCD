//
//  BookmarkDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataIntormation {
    static let bookmark = CoreDataIntormation(
        modelName: "Bookmark",
        storeFileName: "Bookmark.storedata",
        storeOptions:[NSMigratePersistentStoresAutomaticallyOption: true,
                      NSInferMappingModelAutomaticallyOption: true],
        storeType: NSSQLiteStoreType,
        deleteAndRetry: false
    )
}
extension CoreDataCore {
    static let bookmark = CoreDataCore(.bookmark)
}
extension Entity {
    static let bookmark = Entity(name: "Bookmark")
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
    func createBookmark() -> BookmarkItem? {
        return insertNewObject(for: .bookmark) as? BookmarkItem
    }
}
