//
//  KCDeck.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

// swiftlint:disable variable_name
final class Deck: KCManagedObject {
    
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
    @NSManaged var ship_6: Int
}
// swiftlint:eable variable_name

extension Deck {
    
    static var maxShipCount: Int = 7
    
    func setShip(id: Int, for position: Int) {
        
        switch position {
        case 0: ship_0 = id
        case 1: ship_1 = id
        case 2: ship_2 = id
        case 3: ship_3 = id
        case 4: ship_4 = id
        case 5: ship_5 = id
        case 6: ship_6 = id
        default: break // fatalError("Deck.setShip: position out of range.")
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
        case 6: return ship_6
        default: return nil
        }
    }
    
    private func ship(ofId identifier: Int) -> Ship? {
        
        guard let moc = self.managedObjectContext else { return nil }
        
        let req = NSFetchRequest<Ship>(entityName: Ship.entityName)
        req.predicate = NSPredicate(#keyPath(Ship.id), equal: identifier)
        
        guard let ships = try? moc.fetch(req) else { return nil }
        
        return ships.first
    }
    
    subscript(_ index: Int) -> Ship? {
        
        guard let shipId = shipId(of: index) else { return nil }
        
        return ship(ofId: shipId)
    }
    
    subscript(_ range: CountableClosedRange<Int>) -> [Ship] {
        
        return range.flatMap { self[$0] }
    }
}
