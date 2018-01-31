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
    
    @objc let managedObjectContext = ServerDataStore.default.context
    
    @IBOutlet var slotItemController: NSArrayController!
    @IBOutlet var searchField: NSSearchField!
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    @objc var showEquipmentType: Int {
        
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
            return NSPredicate.isNil(#keyPath(SlotItem.equippedShip.lv))
                .and(.isNil(#keyPath(SlotItem.extraEquippedShip.lv)))
            
        case .equiped:
            return NSPredicate.empty
                .and(.isNotNil(#keyPath(SlotItem.equippedShip.lv)))
                .or(.isNotNil(#keyPath(SlotItem.extraEquippedShip.lv)))
        }
    }
    
    @objc var showEquipmentTypeTitle: String {
        
        switch UserDefaults.standard[.showEquipmentType] {
            
        case .all: return LocalizedStrings.allEquipment.string
            
        case .nonEquiped: return LocalizedStrings.unequiped.string
            
        case .equiped: return LocalizedStrings.equiped.string
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
private var objectForTouchBar: [Int: NSTouchBar] = [:]

@available(OSX 10.12.2, *)
extension SlotItemWindowController {
    
    @IBOutlet private var myTouchBar: NSTouchBar? {
        
        get { return objectForTouchBar[hash] }
        set { objectForTouchBar[hash] = newValue }
    }

    override var touchBar: NSTouchBar? {
        
        get {
            if let _ = myTouchBar {
                
                return myTouchBar
            }
            
            var topLevel: NSArray?
            Bundle.main.loadNibNamed(NSNib.Name("SlotItemWindowTouchBar"),
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
