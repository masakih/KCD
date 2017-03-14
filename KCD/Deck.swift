//
//  KCDeck.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

// swiftlint:disable variable_name
class Deck: KCManagedObject {
    @NSManaged var flagship: NSNumber?
    @NSManaged var id: Int
    @NSManaged var member_id: NSNumber?
    @NSManaged var mission_0: Int
    @NSManaged var mission_1: Int
    @NSManaged var mission_2: Int
    @NSManaged var mission_3: Int
    @NSManaged var name: String
    @NSManaged var name_id: NSNumber?
    @NSManaged var ship_0: Int
    @NSManaged var ship_1: Int
    @NSManaged var ship_2: Int
    @NSManaged var ship_3: Int
    @NSManaged var ship_4: Int
    @NSManaged var ship_5: Int
}
// swiftlint:eable variable_name

extension Deck {
    func setShip(id: Int, for position: Int) {
        switch position {
        case 0: return ship_0 = id
        case 1: return ship_1 = id
        case 2: return ship_2 = id
        case 3: return ship_3 = id
        case 4: return ship_4 = id
        case 5: return ship_5 = id
        default: fatalError("Deck.setShip: position out of range.")
        }
    }
    func shipId(of position: Int) -> Int? {
        switch position {
        case 0: return ship_0
        case 1: return ship_1
        case 2: return ship_2
        case 3: return ship_3
        case 4: return ship_4
        case 5: return ship_5
        default: return nil
        }
    }
    private func ship(ofId identifier: Int) -> Ship? {
        guard let moc = self.managedObjectContext else { return nil }
        let req = NSFetchRequest<Ship>(entityName: "Ship")
        req.predicate = NSPredicate(format: "id = %ld", identifier)
        guard let ships = try? moc.fetch(req),
            let ship = ships.first
            else { return nil }
        return ship as Ship
    }
    
    subscript(_ index: Int) -> Ship? {
        guard let shipId = shipId(of: index) else { return nil }
        return ship(ofId: shipId)
    }
}
