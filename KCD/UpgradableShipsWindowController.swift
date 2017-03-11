//
//  UpgradableShipsWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/18.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

private extension Selector {
    static let showHideShip = #selector(UpgradableShipsWindowController.showHideShip(_:))
}

class UpgradableShipsWindowController: NSWindowController {
    let managedObjectContext = ServerDataStore.default.managedObjectContext
    private static var excludeShiIDsCache: [Int] = []
    
    class func isExcludeShipID(_ shipID: Int) -> Bool {
        return excludeShiIDsCache.contains(shipID)
    }
    
    class func keyPathsForValuesAffectingFilterPredicate() -> Set<String> {
        return ["showLevelOneShipInUpgradableList", "showsExcludedShipInUpgradableList"]
    }
    
    private var excludeShiIDsCache: [Int] {
        get {
            return UpgradableShipsWindowController.excludeShiIDsCache
        }
        set {
            UpgradableShipsWindowController.excludeShiIDsCache = newValue
        }
    }
    private func isExcludeShipID(_ shipID: Int) -> Bool {
        return excludeShiIDsCache.contains(shipID)
    }
    
    
    @IBOutlet var contextualMenu: NSMenu!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var shipsController: NSArrayController!
    
    override var windowNibName: String! {
        return "UpgradableShipsWindowController"
    }
    
    dynamic var filterPredicate: NSPredicate? {
        var filterPredicate: NSPredicate? = nil
        var excludeShip: NSPredicate? = nil
        if showLevelOneShipInUpgradableList == false {
            filterPredicate = NSPredicate(format: "lv != 1")
        }
        if showsExcludedShipInUpgradableList == false,
            excludeShiIDs.count != 0 {
            excludeShip = NSPredicate(format: "NOT id IN %@", excludeShiIDs)
        }
        if let filterPredicate = filterPredicate,
            let excludeShip = excludeShip {
            return NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, excludeShip])
        }
        if let filterPredicate = filterPredicate { return filterPredicate }
        if let excludeShip = excludeShip { return excludeShip }
        
        return nil
    }
    
    var showLevelOneShipInUpgradableList: Bool {
        get {
            return UserDefaults.standard.showLevelOneShipInUpgradableList
        }
        set {
            UserDefaults.standard.showLevelOneShipInUpgradableList = newValue
        }
    }
    var showsExcludedShipInUpgradableList: Bool {
        get {
            return UserDefaults.standard.showsExcludedShipInUpgradableList
        }
        set {
            UserDefaults.standard.showsExcludedShipInUpgradableList = newValue
        }
    }
    var excludeShiIDs: [Int] {
        get {
            return (NSArray(contentsOf: excludeShipIDsSaveURL) as? [Int]) ?? []
        }
        set {
            willChangeValue(forKey: "filterPredicate")
            (newValue as NSArray).write(to: excludeShipIDsSaveURL, atomically: true)
            UpgradableShipsWindowController.excludeShiIDsCache = newValue
            didChangeValue(forKey: "filterPredicate")
        }
    }
    private var excludeShipIDsSaveURL: URL {
        return ApplicationDirecrories.support.appendingPathComponent("ExcludeShipIDs")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        excludeShiIDsCache = excludeShiIDs
    }
    
    private func includeShip(shipID: Int) {
        var array = excludeShiIDs
        guard let index = array.index(of: shipID) else { return }
        array.remove(at: index)
        excludeShiIDs = array
    }
    private func excludeShip(shipID: Int) {
        var array = excludeShiIDs
        array.append(shipID)
        excludeShiIDs = array
    }
    
    @IBAction func showHideShip(_ sender: AnyObject?) {
        let row = tableView.clickedRow
        guard let ships = shipsController.arrangedObjects as? [Ship],
            0..<ships.count ~= row
            else { return }
        let shipID = ships[row].id
        if isExcludeShipID(shipID) {
            includeShip(shipID: shipID)
        } else {
            excludeShip(shipID: shipID)
        }
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == .showHideShip {
            let row = tableView.clickedRow
            guard let ships = shipsController.arrangedObjects as? [Ship],
                0..<ships.count ~= row
                else { return false }
            let shipID = ships[row].id
            if isExcludeShipID(shipID) {
                menuItem.title = NSLocalizedString("Show Kanmusu", comment: "UpgradableShipsWindowController menu item")
            } else {
                menuItem.title = NSLocalizedString("Hide Kanmusu", comment: "UpgradableShipsWindowController menu item")
            }
            
            return true
        }
        
        return false
    }
}
