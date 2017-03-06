//
//  BookmarkManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum BookmarkMenuTag: Int {
    case bookmark = 5000
    case separator = 9999
}

class BookmarkManager: NSObject, NSMenuDelegate {
    private static let sharedInstance: BookmarkManager = BookmarkManager()
    
    class func shared() -> BookmarkManager {
        return sharedInstance
    }
    
    private let bookmarksController: NSArrayController
    
    private override init() {
        bookmarksController = NSArrayController()
        super.init()
        bookmarksController.managedObjectContext = self.manageObjectContext
        bookmarksController.entityName = "Bookmark"
        let sort = NSSortDescriptor(key: "order", ascending: true)
        bookmarksController.sortDescriptors = [sort]
        let mainMenu = NSApplication.shared().mainMenu
        let bItem = mainMenu?.item(withTag: BookmarkMenuTag.bookmark.rawValue)
        bookmarkMenu = bItem?.submenu
        bookmarkMenu?.delegate = self
        buildBookmarkMenu()
    }
    
    private(set) var editorStore: BookmarkDataStore = BookmarkDataStore.oneTimeEditor()
    private var bookmarkMenu: NSMenu!
    var manageObjectContext = BookmarkDataStore.default.managedObjectContext
    var bookmarks: [BookmarkItem] {
        bookmarksController.fetch(nil)
        guard let items = bookmarksController.arrangedObjects as? [BookmarkItem]
            else { return [] }
        return items
    }
    
    func createNewBookmark() -> BookmarkItem? {
        guard let maxOrder = bookmarksController.value(forKeyPath: "arrangedObjects.@max.order") as? Int
            else {
                print("BookmarkManager: Can no convert max order to Int")
                return nil
        }
        guard let new = editorStore.insertNewObject(forEntityName: "Bookmark") as? BookmarkItem
            else {
                print("BookmarkManager: Can not insert BookMarkItem")
                return nil
        }
        new.identifier = String(format: "B%@", arguments: [NSDate()])
        new.order = maxOrder + 100
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.editorStore.saveActionCore()
        }
        
        return new
    }
    func menuNeedsUpdate(_ menu: NSMenu) {
        buildBookmarkMenu()
    }
    private func buildBookmarkMenu() {
        for item in bookmarkMenu.items.reversed() {
            if item.tag == BookmarkMenuTag.separator.rawValue { break }
            bookmarkMenu.removeItem(item)
        }
        
        bookmarks.forEach {
            let item = NSMenuItem(title: $0.name, action:  #selector(ExternalBrowserWindowController.selectBookmark(_:)), keyEquivalent: "")
            item.representedObject = $0
            bookmarkMenu.addItem(item)
        }
    }
}
