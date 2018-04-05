//
//  TPValueCalculator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/09/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation


protocol TPValueCalculator {
    
    var value: Int { get }
}

final class ShipTPValueCalculator: TPValueCalculator {
    
    static let kinuKaiNi = 487
    
    let ship: Ship
    
    init(_ ship: Ship) {
        
        self.ship = ship
    }
    
    var value: Int {
        
        if ship.status == 3 {
            
            return 0
        }
        
        let shipTPValue = shipTypeValue(ShipType(rawValue: ship.master_ship.stype.id))
        
        let itemValue = ship.equippedItem.array
            .compactMap { $0 as? SlotItem }
            .map { EquipmentTPValueCalculator($0) }
            .map { $0.value }
            .reduce(0, +)
        
        let extraItemValue = ship.extraItem.flatMap { EquipmentTPValueCalculator($0) }.flatMap { $0.value } ?? 0
        
        return shipTPValue + itemValue + extraItemValue
    }
    
    func shipTypeValue(_ shipType: ShipType?) -> Int {
        
        if ship.master_ship.id == ShipTPValueCalculator.kinuKaiNi {
            
            return 10
        }
        
        guard let type = shipType else { return 0 }
        
        switch type {
            
        case .destroyer: return 5
            
        case .lightCruiser: return 2
            
        case .aviationCruiser: return 4
            
        case .aviationBattleship: return 7
            
        case .submarineAircraftCarrier: return 1
            
        case .seaplaneTender: return 9
            
        case .amphibiousAssaultShip: return 12
            
        case .submarineTender: return 7
            
        case .trainingCruiser: return 6
            
        case .supplyShip: return 15
            
        default: return 0
        }
    }
}

final class EquipmentTPValueCalculator: TPValueCalculator {
    
    let slotItem: SlotItem
    
    init(_ item: SlotItem) {
        
        slotItem = item
    }
    
    var value: Int {
        
        guard let type = EquipmentType(rawValue: slotItem.master_slotItem.type_2) else { return 0 }
        
        switch type {
            
        case .landingCraft: return 8
            
        case .carire: return 5
            
        case .tankShip: return 22
            
        case .onigiri: return 1
            
        default: return 0
        }
    }
}
