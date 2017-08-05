//
//  SlotItemWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/21.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SlotItemWindowController: NSWindowController {
    
    enum ShowType: Int {
        
        case all = -1
        case nonEquiped = 0
        case equiped = 1
    }
    
    let managedObjectContext = ServerDataStore.default.context
    
    @IBOutlet var slotItemController: NSArrayController!
    @IBOutlet var searchField: NSSearchField!
    
    override var windowNibName: String! {
        
        return "SlotItemWindowController"
    }
    
    var showEquipmentType: Int {
        
        get { return UserDefaults.standard[.showEquipmentType].rawValue }
        set {
            notifyChangeValue(forKey: #keyPath(showEquipmentTypeTitle)) {
                
                UserDefaults.standard[.showEquipmentType] = ShowType(rawValue: newValue) ?? .all
            }
            slotItemController.fetchPredicate = filterPredicate
        }
    }
    
    var filterPredicate: NSPredicate? {
        
        switch UserDefaults.standard[.showEquipmentType] {
        case .all:
            return nil
            
        case .nonEquiped:
            return NSPredicate(format: "equippedShip.lv = NULL && extraEquippedShip.lv = NULL")
            
        case .equiped:
            return NSPredicate(format: "equippedShip.lv != NULL || extraEquippedShip.lv != NULL")
        }
    }
    
    var showEquipmentTypeTitle: String {
        
        switch UserDefaults.standard[.showEquipmentType] {
        case .all:
            return NSLocalizedString("All", comment: "show equipment type All")
            
        case .nonEquiped:
            return NSLocalizedString("Unequiped", comment: "show equipment type Unequiped")
            
        case .equiped:
            return NSLocalizedString("Equiped", comment: "show equipment type Equiped")
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        // refresh filter
        let type = showEquipmentType
        showEquipmentType = type
    }
}


@available(OSX 10.12.2, *)
fileprivate var objectForTouchBar: [Int: NSTouchBar] = [:]

@available(OSX 10.12.2, *)
extension SlotItemWindowController {
    
    @IBOutlet var myTouchBar: NSTouchBar? {
        
        get { return objectForTouchBar[hash] }
        set { objectForTouchBar[hash] = newValue }
    }

    override var touchBar: NSTouchBar? {
        
        get {
            if let _ = myTouchBar {
                
                return myTouchBar
            }
            
            var topLevel: NSArray = []
            Bundle.main.loadNibNamed("SlotItemWindowTouchBar",
                                     owner: self,
                                     topLevelObjects: &topLevel)
            return myTouchBar
        }
        set {}
    }
    
    @IBAction func nextShowType(_ sender: AnyObject?) {
        
        let next = (showEquipmentType + 2) % 3 - 1
        showEquipmentType = next
    }
    @IBAction func selectSearchField(_ sender: AnyObject?) {
        
        window!.makeFirstResponder(searchField)
    }
}
