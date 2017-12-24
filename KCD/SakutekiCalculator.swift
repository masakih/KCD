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

extension SakutekiCalculator {
    
    fileprivate func alivedShips(ships: [Ship]) -> [Ship] {
        
        return ships.filter {
            TemporaryDataStore.default.ensuredGuardEscaped(byShipId: $0.id) == nil
        }
    }
}

final class SimpleCalculator: SakutekiCalculator {
    
    
    func calculate(_ ships: [Ship]) -> Double {
        
        return Double(alivedShips(ships: ships).reduce(0) { $0 + $1.sakuteki_0 })
    }
}

final class Formula33: SakutekiCalculator {
    
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
                
                let saku = $1.master_slotItem.saku ?? 0
                let ratio = typeRatio($1)
                let bounus = levelBounus($1)
                let culcSaku = ratio * (Double(truncating: saku) + bounus)
                
                return $0 + "\n\t\($1.name)\tLv.\($1.level)\t\t\(saku)\t\(ratio)\t\(bounus)\t\(culcSaku)"
        }
        
        print("\(shipData)\(itemNames)\n")
        
    }
    
    func calculate(_ ships: [Ship]) -> Double {
        
        Debug.excute(level: .full) {
            ships.forEach(printShipData)
        }
        
        let aliveShips = alivedShips(ships: ships)
        
        // 艦娘の索敵による索敵値
        let saku1 = aliveShips
            .map(normalSakuteki)
            .map(sqrt)
            .reduce(0, +)
        
        // 装備および分岐点係数による索敵値
        let saku2 = aliveShips
            .map(equipsSakuteki)
            .reduce(0, +)
        
        // 艦隊司令部Lv.による影響
        let saku3 = shireiSakuteki()
        
        // 艦隊の艦娘数による影響
        let saku4 = 2 * (6 - aliveShips.count)
        
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
        
        guard let eqType = EquipmentType(rawValue: item.master_slotItem.type_2) else { return 1 }
        
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
                
        guard let eqType = EquipmentType(rawValue: item.master_slotItem.type_2) else { return 1 }
        
        switch eqType {
        case .smallRadar: return 1.25
        case .largeRadar: return 1.4
        case .airplaneSearcher, .searcher: return 1.2
        default: return 0
        }
    }
    
    private func shireiSakuteki() -> Double {
        
        guard let basic = ServerDataStore.default.basic() else { return 0 }
        
        return ceil(0.4 * Double(basic.level))
    }
    
}
