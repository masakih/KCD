//
//  UpgradableShipsWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/18.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class UpgradableShipsWindowController: NSWindowController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    
    private static var excludeShiIDsCache: [Int] = []
    
    class func isExcludeShipID(_ shipID: Int) -> Bool {
        
        return excludeShiIDsCache.contains(shipID)
    }
    
    @objc override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        
        switch key {
            
        case #keyPath(filterPredicate): return [#keyPath(showLevelOneShipInUpgradableList), #keyPath(showsExcludedShipInUpgradableList)]
        
        default: return []
            
        }
    }
    
    private var excludeShiIDsCache: [Int] {
        
        get { return UpgradableShipsWindowController.excludeShiIDsCache }
        set { UpgradableShipsWindowController.excludeShiIDsCache = newValue }
    }
    
    private func isExcludeShipID(_ shipID: Int) -> Bool {
        
        return excludeShiIDsCache.contains(shipID)
    }
    
    
    @IBOutlet private var contextualMenu: NSMenu!
    @IBOutlet private var tableView: NSTableView!
    @IBOutlet private var shipsController: NSArrayController!
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    @objc dynamic var filterPredicate: NSPredicate? {
        
        var levelOnePredicate: NSPredicate?
        var excludeShip: NSPredicate?
        
        if showLevelOneShipInUpgradableList == false {
            
            levelOnePredicate = NSPredicate(#keyPath(Ship.lv), notEqual: 1)
        }
        
        if showsExcludedShipInUpgradableList == false,
            excludeShiIDsCache.count != 0 {
            
            excludeShip = .not(NSPredicate(#keyPath(Ship.id), valuesIn: excludeShiIDsCache))
        }
        
        switch (levelOnePredicate, excludeShip) {
            
        case let (p0?, p1?): return p0.and(p1)
            
        case let (p0?, _): return p0
            
        case let (_, p1?): return p1
            
        default: return nil
        }
    }
    
    @objc var showLevelOneShipInUpgradableList: Bool {
        
        get { return UserDefaults.standard[.showLevelOneShipInUpgradableList] }
        set { UserDefaults.standard[.showLevelOneShipInUpgradableList] = newValue }
    }
    
    @objc var showsExcludedShipInUpgradableList: Bool {
        
        get { return UserDefaults.standard[.showsExcludedShipInUpgradableList] }
        set { UserDefaults.standard[.showsExcludedShipInUpgradableList] = newValue }
    }
    
    var excludeShiIDs: [Int] {
        
        get { return (NSArray(contentsOf: excludeShipIDsSaveURL) as? [Int]) ?? [] }
        set {
            notifyChangeValue(forKey: #keyPath(filterPredicate)) {
                
                (newValue as NSArray).write(to: excludeShipIDsSaveURL, atomically: true)
                UpgradableShipsWindowController.excludeShiIDsCache = newValue
            }
        }
    }
    
    private var excludeShipIDsSaveURL: URL {
        
        return ApplicationDirecrories.support.appendingPathComponent("ExcludeShipIDs")
    }
    
    override func windowWillLoad() {
        
        super.windowWillLoad()
        
        excludeShiIDsCache = excludeShiIDs
    }
    
    private func includeShip(shipID: Int) {
        
        guard let index = excludeShiIDs.index(of: shipID) else {
            
            return
        }
        
        excludeShiIDs.remove(at: index)
    }
    
    private func excludeShip(shipID: Int) {
        
        excludeShiIDs.append(shipID)
    }
    
    @IBAction func showHideShip(_ sender: AnyObject?) {
        
        let row = tableView.clickedRow
        
        guard let ships = shipsController.arrangedObjects as? [Ship] else {
            
            return
        }
        guard case 0..<ships.count = row else {
            
            return
        }
        
        let shipID = ships[row].id
        if isExcludeShipID(shipID) {
            
            includeShip(shipID: shipID)
            
        } else {
            
            excludeShip(shipID: shipID)
        }
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action = menuItem.action else {
            
            return false
        }
        
        switch action {
            
        case #selector(UpgradableShipsWindowController.showHideShip(_:)):
            
            let row = tableView.clickedRow
            
            guard let ships = shipsController.arrangedObjects as? [Ship] else {
                
                return false
            }
            guard case 0..<ships.count = row else {
                
                return false
            }
            
            if isExcludeShipID(ships[row].id) {
                
                menuItem.title = LocalizedStrings.showKanmusu.string
                
            } else {
                
                menuItem.title = LocalizedStrings.hideKanmusu.string
            }
            
            return true
            
        default: return false
            
        }
    }
}
