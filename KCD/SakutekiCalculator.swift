//
//  SakutekiCalculator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/06/18.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

protocol SakutekiCalculator {
    func calculate(_ ships: [Ship]) -> Double
}

class SimpleCalculator: SakutekiCalculator {
    func calculate(_ ships: [Ship]) -> Double {
        return Double(ships.reduce(0) { $0.0 + $0.1.sakuteki_0 })
    }
}

class Formula33: SakutekiCalculator {
    
    let condition: Int
    
    init(_ condition: Int = 1) {
        self.condition = condition
    }
    
    private func printShipData(_ ship: Ship) {
        
        let shipData = "\(ship.name)\t\(normalSakuteki(ship))"
        let itemNames = ship
            .equippedItem
            .array
            .flatMap { $0 as? SlotItem }
            .reduce("") {
                
                let saku = $0.1.master_slotItem.saku ?? 0
                let ratio = typeRatio($0.1)
                let bounus = levelBounus($0.1)
                let culcSaku = ratio * (Double(saku) + bounus)
                
                return $0.0 + "\n\t\($0.1.name)\tLv.\($0.1.level)\t\t\(saku)\t\(ratio)\t\(bounus)\t\(culcSaku)"
        }
        
        print("\(shipData)\(itemNames)\n")
        
    }
    
    func calculate(_ ships: [Ship]) -> Double {
        
        Debug.excute(level: .debug) {
            ships.forEach(printShipData)
        }
        
        let saku1 = ships
            .map(normalSakuteki)
            .map(sqrt)
            .reduce(0, +)
        
        let saku2 = ships
            .map(equipsSakuteki)
            .reduce(0, +)
        
        let saku3 = shireiSakuteki()
        
        let saku4 = 2 * (6 - ships.count)
        
        return saku1 + saku2 - saku3 + Double(saku4)
    }
    
    private func normalSakuteki(_ ship: Ship) -> Double {
        
        let eqSakuteki = ship
            .equippedItem
            .array
            .flatMap { $0 as? SlotItem }
            .flatMap { $0.master_slotItem.saku as? Double }
            .reduce(0, +)
        return Double(ship.sakuteki_0) - eqSakuteki
    }
    
    private func equipsSakuteki(_ ship: Ship) -> Double {
        
        let saku = ship
            .equippedItem
            .array
            .flatMap { $0 as? SlotItem }
            .map(equipSakuteki)
            .reduce(0, +)
        
        return Double(condition) * saku
    }
    
    private func equipSakuteki(_ item: SlotItem) -> Double {
        
        guard let saku = item.master_slotItem.saku as? Double else { return 0 }
        
        let lvBounus = levelBounus(item)
        
        let ratio = typeRatio(item)
        
        return Double(condition) * ratio * (saku + lvBounus)
    }
    private func typeRatio(_ item: SlotItem) -> Double {
        
        let type2 = item.master_slotItem.type_2
        guard let eqType = EquipmentType(rawValue: type2)
            else { return 1 }
        
        switch eqType {
        case .fighter: return 0.6
        case .bomber: return 0.6
        case .attacker: return 0.8
        case .searcher: return 1
        case .airplaneSearcher: return 1.2
        case .airplaneBomber: return 1.1
        case .smallRadar: return 0.6
        case .largeRadar: return 0.6
        case .antiSunmrinerSercher: return 0.6
        case .searchlight: return 0.6
        case .headquaters: return 0.6
        case .pilot: return 0.6
        case .shipPersonnel: return 0.6
        case .largeSonar: return 0.6
        case .largeAirplane: return 0.6
        case .largeSearchlight: return 0.6
        case .airplaneFighter: return 0.6
        case .searcherII: return 1
        case .jetBomber: return 0.6
        default: return 0
        }
    }
    private func levelBounus(_ item: SlotItem) -> Double {
        
        let level = item.level
        
        let ratio = levelRatio(item)
        
        return ratio * sqrt(Double(level))
    }
    private func levelRatio(_ item: SlotItem) -> Double {
        
        let type2 = item.master_slotItem.type_2
        guard let eqType = EquipmentType(rawValue: type2)
            else { return 1 }
        
        switch eqType {
        case .smallRadar: return 1.25
        case .largeRadar: return 1.4
        case .airplaneSearcher, .searcher: return 1.2
        default: return 0
        }
    }
    
    private func shireiSakuteki() -> Double {
        
        guard let basic = ServerDataStore.default.basic()
            else { return 0 }
        
        return ceil(0.4 * Double(basic.level))
    }
    
}
