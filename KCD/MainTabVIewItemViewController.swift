//
//  MainTabVIewItemViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/27.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

@objc
enum ShipTabType: Int {
    
    case all = 0
    case destroyer = 1
    case lightCruiser = 2
    case heavyCruiser = 3
    case aircraftCarrier = 4
    case battleShip = 5
    case submarine = 6
    case other = 7
}

class MainTabVIewItemViewController: NSViewController {
    
    let shipTypeCategories: [[Int]] = [
        [0],    // dummy
        [2],    // destoryer
        [3, 4], // leght cruiser
        [5, 6], // heavy crusier
        [7, 11, 16, 18],    // aircraft carrier
        [8, 9, 10, 12], // battle ship
        [13, 14],   // submarine
        [1, 15, 17, 19, 20, 21, 22]
    ]
    
    @objc dynamic var hasShipTypeSelector: Bool { return false }
    @objc dynamic var selectedShipType: ShipTabType = .all
    
    var shipTypePredicte: NSPredicate? {
        
        switch selectedShipType {
        case .all:
            return nil
            
        case .destroyer, .lightCruiser, .heavyCruiser,
             .aircraftCarrier, .battleShip, .submarine:
            return NSPredicate(format: "master_ship.stype.id IN %@", shipTypeCategories[selectedShipType.rawValue])
            
        case .other:
            let omitTypes = shipTypeCategories
                .enumerated()
                .filter { $0.offset != 0 && $0.offset != 7 }
                .flatMap { $0.element }
            return NSPredicate(format: "NOT master_ship.stype.id IN %@", omitTypes)
        }
    }
}
