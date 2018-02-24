//
//  BookmarkManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private enum BookmarkMenuTag: Int {
    
    case bookmark = 5000
    
    case separator = 9999
    case bookmarkItem = 999999
}

final class BookmarkManager: NSObject, NSMenuDelegate {
    
    static let shared = BookmarkManager()
    
    private override init() {
        
        super.init()
        
        bookmarksController.managedObjectContext = self.manageObjectContext
        bookmarksController.entityName = Bookmark.entityName
        let sort = NSSortDescriptor(key: #keyPath(Bookmark.order), ascending: true)
        bookmarksController.sortDescriptors = [sort]
        
        let mainMenu = NSApplication.shared.mainMenu
        let bItem = mainMenu?.item(withTag: BookmarkMenuTag.bookmark.rawValue)
        bookmarkMenu = bItem?.submenu
        bookmarkMenu?.delegate = self
        buildBookmarkMenu()
    }
    
    let editorStore: BookmarkDataStore = BookmarkDataStore.oneTimeEditor()
    let manageObjectContext = BookmarkDataStore.default.context
    private let bookmarksController = NSArrayController()
    
    private var bookmarkMenu: NSMenu!
    
    var bookmarks: [Bookmark] {
        
        bookmarksController.fetch(nil)
        
        guard let items = bookmarksController.arrangedObjects as? [Bookmark] else { return [] }
        
        return items
    }
    
    func createNewBookmark(configurator: @escaping (Bookmark) -> Bool) -> Bookmark? {
        
        guard let maxOrder = bookmarksController.value(forKeyPath: "arrangedObjects.@max.order") as? Int else {
            
            return Logger.shared.log("BookmarkManager: Can no convert max order to Int", value: nil)
        }
        
        let editorStore: BookmarkDataStore = BookmarkDataStore.oneTimeEditor()
        
        guard let new = editorStore.sync(execute: { editorStore.createBookmark() }) else {
            
            return Logger.shared.log("BookmarkManager: Can not insert BookMarkItem", value: nil)
        }
        
        return editorStore.sync {
            
            new.identifier = String(format: "B%@", arguments: [NSDate()])
            new.order = maxOrder + 100
            
            if !configurator(new) {
                
                editorStore.delete(new)
                
                return nil
            }
            
            editorStore.save(errorHandler: editorStore.presentOnMainThread)
            
            return new
        }
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        buildBookmarkMenu()
    }
    
    private func buildBookmarkMenu() {
        
        bookmarkMenu
            .items
            .filter { $0.tag == BookmarkMenuTag.bookmarkItem.rawValue }
            .forEach(bookmarkMenu.removeItem)
        
        bookmarks.forEach {
            
            let item = NSMenuItem(title: $0.name,
                                  action: #selector(ExternalBrowserWindowController.selectBookmark(_:)),
                                  keyEquivalent: "")
            item.representedObject = $0
            item.tag = BookmarkMenuTag.bookmarkItem.rawValue
            bookmarkMenu.addItem(item)
        }
    }
}
