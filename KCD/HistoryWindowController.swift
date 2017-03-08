//
//  HistoryWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/20.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate protocol Markable {
    var marked: Bool { get set }
}
extension DropShipHistory: Markable {
    var marked: Bool {
        get { return mark }
        set { mark = newValue }
    }
}
extension KenzoHistory: Markable {
    var marked: Bool {
        get { return mark }
        set { mark = newValue }
    }
}
extension KaihatuHistory: Markable {
    var marked: Bool {
        get { return mark }
        set { mark = newValue }
    }
}

fileprivate extension Selector {
    static let addMark = #selector(HistoryWindowController.addMark(_:))
}

class HistoryWindowController: NSWindowController {
    fileprivate enum HistoryWindowTabIndex: Int {
        case kaihatuHistory = 0
        case kenzoHistory = 1
        case dropHistory = 2
    }
    
    fileprivate struct SelectionInfo {
        let controller: NSArrayController
        let predicateFormat: String
        let tableView: NSTableView
        let entityName: Entity
        let pickUpPredicateFormat: String
        
        init(_ owner: HistoryWindowController) {
            switch owner.swiftSelectedTabIndex {
            case .kaihatuHistory:
                controller = owner.kaihatuHistoryController
                predicateFormat = "name contains $value"
                tableView = owner.kaihatuHistoryTableView
                entityName = .kaihatuHistory
                pickUpPredicateFormat = "date = %@ AND name = %@"
            case .kenzoHistory:
                controller = owner.kenzoHistoryController
                predicateFormat = "name contains $value"
                tableView = owner.kenzoHistoryTableView
                entityName = .kenzoHistory
                pickUpPredicateFormat = "date = %@ AND name = %@"
            case .dropHistory:
                controller = owner.dropHistoryController
                predicateFormat = "shipName contains $value"
                tableView = owner.dropHistoryTableView
                entityName = .dropShipHistory
                pickUpPredicateFormat = "date = %@ AND mapCell = %ld"
            }
        }
    }
    
    let manageObjectContext = LocalDataStore.default.managedObjectContext
    
    @IBOutlet var kaihatuHistoryController: NSArrayController!
    @IBOutlet var kenzoHistoryController: NSArrayController!
    @IBOutlet var dropHistoryController: NSArrayController!
    
    @IBOutlet var kaihatuHistoryTableView: NSTableView!
    @IBOutlet var kenzoHistoryTableView: NSTableView!
    @IBOutlet var dropHistoryTableView: NSTableView!
    
    @IBOutlet var searchField: NSSearchField!
    
    var selectedTabIndex: Int = 0 {
        didSet {
            HistoryWindowTabIndex(rawValue: selectedTabIndex)
                .map { swiftSelectedTabIndex = $0 }
        }
    }
    fileprivate var swiftSelectedTabIndex: HistoryWindowTabIndex = .kaihatuHistory
    override var windowNibName: String! {
        return "HistoryWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let info = SelectionInfo(self)
        
        searchField.bind(NSPredicateBinding,
                         to: info.controller,
                         withKeyPath: NSFilterPredicateBinding,
                         options: [NSPredicateFormatBindingOption: info.predicateFormat])
    }
    
    @IBAction func delete(_ sender: AnyObject?) {
        let store = LocalDataStore.oneTimeEditor()
        SelectionInfo(self)
            .controller
            .selectedObjects
            .flatMap { $0 as? [NSManagedObject] }
            .flatMap { $0 }
            .map { $0.objectID }
            .map { store.object(with: $0) }
            .forEach { store.delete($0) }
    }
    
    @IBAction func addMark(_ sender: AnyObject?) {
        let info = SelectionInfo(self)
        let clickedRow = info.tableView.clickedRow
        guard let items = info.controller.arrangedObjects as? [Any],
            0..<items.count ~= clickedRow
            else { return }
        let clickedObject = items[clickedRow]
        
        let p: NSPredicate? = {
            switch clickedObject {
            case let obj as KaihatuHistory:
                return NSPredicate(format: info.pickUpPredicateFormat,
                                   argumentArray: [obj.date, obj.name])
            case let obj as KenzoHistory:
                return NSPredicate(format: info.pickUpPredicateFormat,
                                   argumentArray: [obj.date, obj.name])
            case let obj as DropShipHistory:
                return NSPredicate(format: info.pickUpPredicateFormat,
                                   argumentArray: [obj.date, obj.mapCell])
            default:
                return nil
            }
        }()
        guard let predicate = p else { return }
        
        let store = LocalDataStore.oneTimeEditor()
        if let a = try? store.objects(with: info.entityName,
                             predicate: predicate),
            let item = a.first,
            var history = item as? Markable {
            history.marked = !history.marked
        }
        store.saveActionCore()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == .addMark {
            menuItem.isEnabled = false
            
            let info = SelectionInfo(self)
            let clickedRow = info.tableView.clickedRow
            guard let items = info.controller.arrangedObjects as? [Any],
                0..<items.count ~= clickedRow,
                let clickedObject = items[clickedRow] as? Markable
                else { return false }
            
            menuItem.isEnabled = true
            if clickedObject.marked {
                menuItem.title = NSLocalizedString("Remove mark", comment: "Remove history mark.")
            } else {
                menuItem.title = NSLocalizedString("Add mark", comment: "Add history mark.")
            }
            return true
        }
        
        return false
    }
}

@available(OSX 10.12.2, *)
fileprivate var objectForTouchBar:[Int: NSTouchBar] = [:]
fileprivate var object1ForTouchBar:[Int: NSButton] = [:]

@available(OSX 10.12.2, *)
extension HistoryWindowController {
    @IBOutlet var myTouchBar: NSTouchBar? {
        get {
            return objectForTouchBar[hashValue]
        }
        set {
            objectForTouchBar[hashValue] = newValue
        }
    }
    @IBOutlet var searchButton: NSButton? {
        get {
            return object1ForTouchBar[hashValue]
        }
        set {
            object1ForTouchBar[hashValue] = newValue
        }
    }
    
    override var touchBar: NSTouchBar? {
        get {
            if let _ = myTouchBar {
                return myTouchBar
            }
            var topLevel: NSArray = []
            Bundle.main.loadNibNamed("HistoryWindowTouchBar",
                                     owner: self,
                                     topLevelObjects: &topLevel)
            return myTouchBar
        }
        set {}
    }
    
    @IBAction func selectSearchField(_ sender: AnyObject?) {
        window!.makeFirstResponder(searchField!)
    }
}

extension HistoryWindowController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return tableView.make(withIdentifier: tableColumn!.identifier, owner: nil)
    }
}

extension HistoryWindowController: NSTabViewDelegate {
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        searchField.unbind(NSPredicateBinding)
        
        let info = SelectionInfo(self)
        
        searchField.bind(NSPredicateBinding,
                         to: info.controller,
                         withKeyPath: NSFilterPredicateBinding,
                         options: [NSPredicateFormatBindingOption: info.predicateFormat])
    }
}
