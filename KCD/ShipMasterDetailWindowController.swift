//
//  ShipMasterDetailWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ShipMasterDetailWindowController: NSWindowController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    @objc let fleetManager: FleetManager = {
        
        return AppDelegate.shared.fleetManager ?? FleetManager()
    }()
    let specNames = [
        "id", "name", "shortTypeName",
        "slot_0", "slot_1", "slot_2", "slot_3", "slot_4",
        "onslot_0", "onslot_1", "onslot_2", "onslot_3", "onslot_4",
        "leng", "slot_ex", "sakuteki_0", "sakuteki_1"
    ]
    
    @IBOutlet private var shipController: NSArrayController!
    @IBOutlet private var fleetMemberController: NSArrayController!
    @IBOutlet private var deckController: NSArrayController!
    @IBOutlet private weak var decksView: NSTableView!
    @IBOutlet private weak var shipsView: NSTableView!
    @IBOutlet private weak var fleetMemberView: NSTableView!
    @IBOutlet private weak var sally: NSTextField!
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    @objc dynamic var selectedDeck: Deck? {
        
        didSet {
            fleetShips = selectedDeck?[0...6] ?? []
        }
    }
    
    @objc dynamic var fleetShips: [Ship] = []
    
    @objc dynamic var selectedShip: Ship? {
        
        didSet { buildSpec() }
    }
    @objc dynamic var spec: [[String: Any]] = []
    
    @objc dynamic var equipments: NSArray?
    
    private func buildSpec() {
        
        guard let selectedShip = selectedShip else { return }
        
        spec = specNames.flatMap { key -> [String: Any]? in
            
            guard let v = selectedShip.value(forKeyPath: key) else { return nil }
            
            return ["name": key, "value": v]
        }
        equipments = selectedShip.equippedItem.array as NSArray?
    }
    
    @IBAction func applySally(_ sender: AnyObject?) {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let i = selectedShip?.objectID else { return }
        guard let ship = store.object(of: Ship.entity, with: i) else { return }
        
        ship.sally_area = sally.integerValue as NSNumber
    }
}

extension ShipMasterDetailWindowController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        guard let tableView = notification.object as? NSTableView else { return }
        
        let controller = [
            (shipsView, shipController),
            (fleetMemberView, fleetMemberController),
            (decksView, deckController)
            ]
            .lazy
            .filter { $0.0 == tableView }
            .flatMap { $0.1 }
            .first
        
        if let selectedObjects = controller?.selectedObjects as? [Ship] {
            
            selectedShip = selectedObjects.first
            
        } else if let selectedObjects = controller?.selectedObjects as? [Deck] {
        
            selectedDeck = selectedObjects.first
        }
    }
}
