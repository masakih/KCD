//
//  KCDeck.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class Deck: KCManagedObject {
    @NSManaged var flagship: NSNumber?
    @NSManaged var id: Int
    @NSManaged var member_id: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var mission_0: Int   // swiftlint:disable:this variable_name
    @NSManaged var mission_1: Int   // swiftlint:disable:this variable_name
    @NSManaged var mission_2: Int   // swiftlint:disable:this variable_name
    @NSManaged var mission_3: Int   // swiftlint:disable:this variable_name
    @NSManaged var name: String // swiftlint:disable:this variable_name
    @NSManaged var name_id: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var ship_0: Int  // swiftlint:disable:this variable_name
    @NSManaged var ship_1: Int  // swiftlint:disable:this variable_name
    @NSManaged var ship_2: Int  // swiftlint:disable:this variable_name
    @NSManaged var ship_3: Int  // swiftlint:disable:this variable_name
    @NSManaged var ship_4: Int  // swiftlint:disable:this variable_name
    @NSManaged var ship_5: Int  // swiftlint:disable:this variable_name
}

extension Deck {
    private func shipId(ofPosition position: Int) -> Int? {
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
        guard let shipId = shipId(ofPosition: index) else { return nil }
        return ship(ofId: shipId)
    }
}
