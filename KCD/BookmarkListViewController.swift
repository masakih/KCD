//
//  BookmarkListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol BookmarkListViewControllerDelegate: class {
    func didSelectBookmark(_ bookmark: Bookmark)
}

fileprivate struct DragingType {
    static let bookmarkItem = "com.masakih.KCD.BookmarkItem"
}

class BookmarkListViewController: NSViewController {
    let managedObjectContext = BookmarkManager.shared().manageObjectContext
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var bookmarkController: NSArrayController!
    @IBOutlet var contextMenu: NSMenu!
    @IBOutlet var popover: NSPopover!
    
    weak var delegate: BookmarkListViewControllerDelegate?
    var editorController: BookmarkEditorViewController?
    
    // tableView support
    var objectRange: CountableClosedRange = 0...0
    
    override var nibName: String! {
        return "BookmarkListViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorController = BookmarkEditorViewController()
        popover.contentViewController = editorController
        
        tableView.register(forDraggedTypes: [DragingType.bookmarkItem])
        tableView.setDraggingSourceOperationMask(.move, forLocal: true)
    }
    
    @IBAction func editBookmark(_ sender: AnyObject?) {
        let clickedRow = tableView.clickedRow
        guard let bookmarks = bookmarkController.arrangedObjects as? [Any],
            0..<bookmarks.count ~= clickedRow
            else { return }
        
        editorController?.representedObject = bookmarks[clickedRow]
        popover.show(relativeTo: tableView.rect(ofRow: clickedRow), of: tableView, preferredEdge: .minY)
    }
    @IBAction func deleteBookmark(_ sender: AnyObject?) {
        let clickedRow = tableView.clickedRow
        guard let bookmarks = bookmarkController.arrangedObjects as? [Any],
            0..<bookmarks.count ~= clickedRow
            else { return }
        
        bookmarkController.remove(atArrangedObjectIndex: clickedRow)
    }
}

extension BookmarkListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func reorderingBoolmarks() {
        guard let objects = bookmarkController.arrangedObjects as? [Bookmark] else { return }
        var order = 100
        objects.forEach {
            $0.order = order
            order += 100
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView,
            let bookmarks = bookmarkController.arrangedObjects as? [Bookmark]
            else { return }
        let selection = tableView.selectedRow
        tableView.deselectAll(nil)
        guard 0..<bookmarks.count ~= selection
            else { return }
        delegate?.didSelectBookmark(bookmarks[selection])
    }
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let objects = bookmarkController.arrangedObjects as? [NSPasteboardWriting]
            else { return nil }
        return objects[row]
    }
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        guard let first = rowIndexes.first,
            let last = rowIndexes.last
            else { return }
        objectRange = first...last
    }
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        objectRange = 0...0
    }
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        guard dropOperation == .above,
            !(objectRange ~= row),
            let tableView = info.draggingSource() as? NSTableView,
            tableView == self.tableView
            else { return [] }
        return .move
    }
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        tableView.beginUpdates()
        defer { tableView.endUpdates() }
        
        let targetOrder: Int = {
            guard let objects = bookmarkController.arrangedObjects as? [Any],
                1...objects.count ~= row,
                let target = objects[row - 1] as? Bookmark
                else { return 0 }
            return target.order
        }()
        guard let items = info.draggingPasteboard().pasteboardItems
            else { return false }
        let store = BookmarkManager.shared().editorStore
        items.enumerated().forEach {
            guard let data = $0.element.data(forType: DragingType.bookmarkItem),
                let uri = NSKeyedUnarchiver.unarchiveObject(with: data) as? URL,
                let oID = managedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri),
                let bookmark = store.object(with: oID) as? Bookmark
                else { return }
            bookmark.order = targetOrder + $0.offset + 1
        }
        store.saveActionCore()
        bookmarkController.rearrangeObjects()
        reorderingBoolmarks()
        bookmarkController.rearrangeObjects()
        
        return true
    }
}
