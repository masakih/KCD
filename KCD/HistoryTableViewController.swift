//
//  HistoryTableViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private protocol Markable {
    
    var mark: Bool { get set }
}

private protocol HistoryObject {
    
    var date: Date { get }
}

extension DropShipHistory: Markable, HistoryObject {}
extension KenzoHistory: Markable, HistoryObject {}
extension KaihatuHistory: Markable, HistoryObject {}

enum MenuItemTag: Int {
    
    case delete = 314
    
    case addMark = 50000
}

class HistoryTableViewController: NSViewController {
    
    // Subbclass MUST override these.
    var predicateFormat: String { fatalError("Subbclass MUST implement.") }
    func objects(of predicate: NSPredicate?, in store: LocalDataStore) throws -> [NSManagedObject] {
        
        fatalError("Subbclass MUST implement.")
    }
    
    @IBOutlet var controller: NSArrayController!
    @IBOutlet var tableView: NSTableView!
    
    @IBAction func delete(_ sender: AnyObject?) {
        
        let store = LocalDataStore.oneTimeEditor()
        
        guard let controller = controller else { return }
        guard let selection = controller.selectedObjects as? [NSManagedObject] else { return }
        
        let selectedIndex = controller.selectionIndex
        selection
            .lazy
            .map { $0.objectID }
            .map(store.object(with:))
            .forEach(store.delete)
        
        if selectedIndex > 1 {
            
            controller.setSelectionIndex(selectedIndex - 1)
        }
    }
    
    @IBAction func addMark(_ sender: AnyObject?) {
        
        guard let clickedRow = tableView?.clickedRow else { return }
        guard let items = controller?.arrangedObjects as? [HistoryObject] else { return }
        guard case 0..<items.count = clickedRow else { return }
        
        let clickedObject = items[clickedRow]
        let predicate = NSPredicate(#keyPath(KenzoMark.date), equal: clickedObject.date)
        
        let store = LocalDataStore.oneTimeEditor()
        
        if let items = try? objects(of: predicate, in: store),
            var history = items.first as? Markable {
            
            history.mark = !history.mark
        }
        
        store.save()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let itemTag = MenuItemTag(rawValue: menuItem.tag) else { return false }
        
        switch itemTag {
        case .delete:
            return controller.selectionIndex != -1
            
        case .addMark:
            menuItem.isEnabled = false
            guard let clickedRow = tableView?.clickedRow else { return false }
            guard let items = controller?.arrangedObjects as? [Markable] else { return false }
            guard case 0..<items.count = clickedRow else { return false }
            
            let clickedObject = items[clickedRow]
            menuItem.isEnabled = true
            if clickedObject.mark {
                
                menuItem.title = LocalizedStrings.removeMark.string
                
            } else {
                
                menuItem.title = LocalizedStrings.addMark.string
            }
        }
        
        return true
    }
}

extension HistoryTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        return tableColumn
            .flatMap { $0.identifier }
            .flatMap { tableView.makeView(withIdentifier: $0, owner: nil) }
    }
}

final class KaihatsuHistoryTableViewController: HistoryTableViewController {
    
    override var predicateFormat: String { return "name contains $value" }
    override func objects(of predicate: NSPredicate?, in store: LocalDataStore) throws -> [NSManagedObject] {
        
        return try store.objects(of: KaihatuHistory.entity, predicate: predicate)
    }
}

final class KenzoHistoryTableViewController: HistoryTableViewController {
    
    override var predicateFormat: String { return "name contains $value" }
    override func objects(of predicate: NSPredicate?, in store: LocalDataStore) throws -> [NSManagedObject] {
        
        return try store.objects(of: KenzoHistory.entity, predicate: predicate)
    }
}

final class DropShipHistoryTableViewController: HistoryTableViewController {
    
    override var predicateFormat: String { return "shipName contains $value" }
    override func objects(of predicate: NSPredicate?, in store: LocalDataStore) throws -> [NSManagedObject] {
        
        return try store.objects(of: DropShipHistory.entity, predicate: predicate)
    }
}
