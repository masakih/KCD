//
//  FleetManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let DidPrepareFleet = Notification.Name("com.masakih.KCD.Notification.DidPrepareFleet")
}

class FleetManager: NSObject {
    override init() {
        super.init()
        setupFleets()
    }
    
    private(set) var fleets: [Fleet] = []
    private var fleetController: NSArrayController!
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "arrangedObjects.ships" {
            setNewFleetNumberToShip()
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    private func setupFleetController() {
        fleetController = NSArrayController(content: fleets)
        fleetController.addObserver(self, forKeyPath: "arrangedObjects.ships", context: nil)
    }
    private func setupFleets() {
        fleets = (1...4).flatMap { Fleet(number: $0) }
        guard fleets.count == 4 else { return print("Can not create Fleet") }
        if fleets[0].ships.isEmpty {
            let center = NotificationCenter.default
            var token: NSObjectProtocol!
            token = center.addObserver(forName: .PortAPIReceived, object: nil, queue: nil) {_ in 
                center.removeObserver(token)
                self.setupFleetController()
                center.post(name: .DidPrepareFleet, object: self)
            }
        }
        else { setupFleetController() }
    }
    
    private func setNewFleetNumberToShip() {
        let store = ServerDataStore.oneTimeEditor()
        
        // clear all
        store.shipsInFleet().forEach { $0.fleet = 0 as NSNumber }
        
        // set
        fleets.enumerated().forEach { (index, fleet) in
            fleet.ships.forEach {
                store.ship(byId: $0.id)?.fleet = (index + 1) as NSNumber
            }
        }
    }
}