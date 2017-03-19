//
//  HistoryTableViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate protocol Markable {
    var marked: Bool { get set }
}
fileprivate protocol HistoryObject {
    var date: Date { get }
}

extension DropShipHistory: Markable, HistoryObject {
    var marked: Bool {
        get { return mark }
        set { mark = newValue }
    }
}
extension KenzoHistory: Markable, HistoryObject {
    var marked: Bool {
        get { return mark }
        set { mark = newValue }
    }
}
extension KaihatuHistory: Markable, HistoryObject {
    var marked: Bool {
        get { return mark }
        set { mark = newValue }
    }
}

enum MenuItemTag: Int {
    case delete = 314
    
    case addMark = 50000
}

class HistoryTableViewController: NSViewController {
    var pickUpPredicateFormat: String { return "date = %@" }
    var predicateFormat: String { return "" }
    var entityType: NSManagedObject.Type? { return nil }
    
    @IBOutlet var controller: NSArrayController!
    @IBOutlet var tableView: NSTableView!
    
    @IBAction func delete(_ sender: AnyObject?) {
        let store = LocalDataStore.oneTimeEditor()
        guard let controller = controller,
            let selection = controller.selectedObjects as? [NSManagedObject]
            else { return }
        let selectedIndex = controller.selectionIndex
        selection
            .forEach { store.delete(store.object(with: $0.objectID)) }
        if selectedIndex > 1 {
            controller.setSelectionIndex(selectedIndex - 1)
        }
    }
    @IBAction func addMark(_ sender: AnyObject?) {
        guard let entityType = entityType,
            let clickedRow = tableView?.clickedRow,
            let items = controller?.arrangedObjects as? [HistoryObject],
            0..<items.count ~= clickedRow
            else { return }
        let clickedObject = items[clickedRow]
        let predicate = NSPredicate(format: pickUpPredicateFormat,
                                    argumentArray: [clickedObject.date])
        let store = LocalDataStore.oneTimeEditor()
        if let a = try? store.objects(with: Entity(name: entityType.entityName, type: entityType),
                                      predicate: predicate),
            let item = a.first,
            var history = item as? Markable {
            history.marked = !history.marked
        }
        store.save()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let itemTag = MenuItemTag(rawValue: menuItem.tag)
            else { return false }
        switch itemTag {
        case .delete:
            return controller.selectionIndex != -1
        case .addMark:
            menuItem.isEnabled = false
            guard let clickedRow = tableView?.clickedRow,
                let items = controller?.arrangedObjects as? [Markable],
                0..<items.count ~= clickedRow
                else { return false }
            let clickedObject = items[clickedRow]
            menuItem.isEnabled = true
            if clickedObject.marked {
                menuItem.title = NSLocalizedString("Remove mark", comment: "Remove history mark.")
            } else {
                menuItem.title = NSLocalizedString("Add mark", comment: "Add history mark.")
            }
        }
        
        return true
    }
}
extension HistoryTableViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return tableColumn
            .flatMap { $0.identifier }
            .flatMap { tableView.make(withIdentifier: $0, owner: nil) }
    }
}

class KaihatsuHistoryTableViewController: HistoryTableViewController {
    override var predicateFormat: String { return "name contains $value" }
    override var entityType: NSManagedObject.Type? { return KaihatuHistory.self }
}
class KenzoHistoryTableViewController: HistoryTableViewController {
    override var predicateFormat: String { return "name contains $value" }
    override var entityType: NSManagedObject.Type? { return KenzoHistory.self }
}
class DropShipHistoryTableViewController: HistoryTableViewController {
    override var predicateFormat: String { return "shipName contains $value" }
    override var entityType: NSManagedObject.Type? { return DropShipHistory.self }
}
