//
//  HistoryWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/20.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class HistoryWindowController: NSWindowController {
    
    private enum HistoryWindowTabIndex: Int {
        
        case kaihatuHistory = 0
        case kenzoHistory = 1
        case dropHistory = 2
    }
    
    @objc let manageObjectContext = LocalDataStore.default.context
    
    @IBOutlet var tabView: NSTabView!
    @IBOutlet var kaihatsuTableVC: KaihatsuHistoryTableViewController!
    @IBOutlet var kenzoTableVC: KenzoHistoryTableViewController!
    @IBOutlet var dropShipTableVC: DropShipHistoryTableViewController!
    
    @IBOutlet var searchField: NSSearchField!
    
    private var currentSelection: HistoryTableViewController? {
        
        didSet {
            window?.makeFirstResponder(currentSelection?.tableView)
            
            if let controller = currentSelection?.controller,
                let predicateFormat = currentSelection?.predicateFormat {
                
                searchField.bind(.predicate,
                                 to: controller,
                                 withKeyPath: NSBindingName.filterPredicate.rawValue,
                                 options: [.predicateFormat: predicateFormat])
            } else {
                
                searchField.unbind(.predicate)
            }
        }
    }
    
    @objc var selectedTabIndex: Int = -1 {
        
        didSet {
            guard let tabIndex = HistoryWindowTabIndex(rawValue: selectedTabIndex) else { return }
            
            switch tabIndex {
            case .kaihatuHistory:
                currentSelection = kaihatsuTableVC
                
            case .kenzoHistory:
                currentSelection = kenzoTableVC
                
            case .dropHistory:
                currentSelection = dropShipTableVC
            }
        }
    }
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let vcs: [NSViewController] = [kaihatsuTableVC, kenzoTableVC, dropShipTableVC]
        zip(vcs, tabView.tabViewItems).forEach { $0.1.viewController = $0.0 }
        
        selectedTabIndex = 0
    }
    
    @IBAction func delete(_ sender: AnyObject?) {
        
        currentSelection?.delete(sender)
    }
}

@available(OSX 10.12.2, *)
private var objectForTouchBar: [Int: NSTouchBar] = [:]
private var object1ForTouchBar: [Int: NSButton] = [:]

@available(OSX 10.12.2, *)
extension HistoryWindowController {
    
    @IBOutlet var myTouchBar: NSTouchBar? {
        
        get { return objectForTouchBar[hashValue] }
        set { objectForTouchBar[hashValue] = newValue }
    }
    
    @IBOutlet var searchButton: NSButton? {
        
        get { return object1ForTouchBar[hashValue] }
        set { object1ForTouchBar[hashValue] = newValue }
    }
    
    override var touchBar: NSTouchBar? {
        
        get {
            if let _ = myTouchBar {
                
                return myTouchBar
            }
            var topLevel: NSArray?
            Bundle.main.loadNibNamed(NSNib.Name("HistoryWindowTouchBar"),
                                     owner: self,
                                     topLevelObjects: &topLevel)
            
            return myTouchBar
        }
        set {}
    }
    
    @IBAction func selectSearchField(_ sender: AnyObject?) {
        
        window?.makeFirstResponder(searchField!)
    }
}
