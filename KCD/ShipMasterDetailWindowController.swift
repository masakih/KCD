//
//  ShipMasterDetailWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ShipMasterDetailWindowController: NSWindowController {
    let managedObjectContext = ServerDataStore.default.context
    let fleetManager: FleetManager = {
        return AppDelegate.shared.fleetManager
    }()
    let specNames = [
        "name", "shortTypeName",
        "slot_0", "slot_1", "slot_2", "slot_3", "slot_4",
        "onslot_0", "onslot_1", "onslot_2", "onslot_3", "onslot_4",
        "leng", "slot_ex", "id"
    ]
    
    @IBOutlet var shipController: NSArrayController!
    @IBOutlet var fleetMemberController: NSArrayController!
    @IBOutlet weak var shipsView: NSTableView!
    @IBOutlet weak var fleetMemberView: NSTableView!
    @IBOutlet weak var sally: NSTextField!
    
    override var windowNibName: String! {
        return "ShipMasterDetailWindowController"
    }
    
    dynamic var selectedShip: Ship? {
        didSet { buildSpec() }
    }
    dynamic var spec: [[String: AnyObject]] = []
    
    var equipments: NSArray?
    
    private func buildSpec() {
        guard let selectedShip = selectedShip else { return }
        spec = specNames.flatMap { (s: String) -> [String: AnyObject]? in
            guard let v = selectedShip.value(forKeyPath: s) else { return nil }
            var d = [String: AnyObject]()
            d["name"] = s as AnyObject?
            d["value"] = v as AnyObject?
            return d
        }
        equipments = selectedShip.equippedItem.array as NSArray?
    }
    
    @IBAction func applySally(_ sender: AnyObject?) {
        let store = ServerDataStore.oneTimeEditor()
        guard let i = selectedShip?.objectID,
            let ship = store.object(with: i) as? Ship
            else { return }
        ship.sally_area = sally.integerValue as NSNumber
    }
}

extension ShipMasterDetailWindowController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        let controller = [
            (shipsView, shipController),
            (fleetMemberView, fleetMemberController)
            ]
            .filter { $0.0 == tableView }
            .first
        guard let selectedObjects = controller?.1.selectedObjects as? [Ship],
            selectedObjects.count != 0 else { return }
        selectedShip = selectedObjects[0]
    }
}
