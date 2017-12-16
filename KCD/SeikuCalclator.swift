//
//  SeikuCalclator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/08/20.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

private let seikuEffectiveTypes = [6, 7, 8, 11, 45, 56, 57, 58]

private let fighterTypes =              [ 6]
private let bomberTypes =               [ 7]
private let attackerTypes =             [ 8]
private let floatplaneBomberTypes =     [11]
private let floatplaneFighterTypes =    [45]
private let jetFighter =                [56]
private let jetBomberTypes =            [57]
private let jetAttackerTypes =          [58]

// swiftlint:disable comma
private let fighterBonus: [Double] =            [0, 0, 2, 5, 9, 14, 14, 22]
private let bomberBonus: [Double] =             [0, 0, 0, 0, 0,  0,  0,  0]
private let attackerBonus: [Double] =           [0, 0, 0, 0, 0,  0,  0,  0]
private let floatplaneBomberBonus: [Double] =   [0, 0, 1, 1, 1,  3,  3,  6]
private let floatplaneFighterBonus: [Double] =  [0, 0, 2, 5, 9, 14, 14, 22]
private let jetBomberBonus: [Double] =          [0, 0, 0, 0, 0,  0,  0,  0]
// swiftlint:enable comma

//                             sqrt 0, 1,     2.5,   4,     5.5,   7,     8.5,   10
private let skillBonus: [Double] = [0, 1.000, 1.581, 2.000, 2.345, 2.645, 2.915, 3.162]


final class SeikuCalclator {
    
    let ship: Ship
    
    init(ship: Ship) {
        
        self.ship = ship
    }
    
    var seiku: Int {
        
        let guardEscaped = TemporaryDataStore.default.ensuredGuardEscaped(byShipId: ship.id)
        guard guardEscaped == nil else { return 0 }
        
        return (0...4).map(slotSeiku).map { Int($0) }.reduce(0, +)
    }
    
    var totalSeiku: Int {
        
        let guardEscaped = TemporaryDataStore.default.ensuredGuardEscaped(byShipId: ship.id)
        guard guardEscaped == nil else { return 0 }
        
        return (0...4).map(seiku).reduce(0, +)
    }
    
    private func slotItem(at index: Int) -> SlotItem? {
        
        return ServerDataStore.default.slotItem(by: ship.slotItemId(index))
    }
    
    private func typeBonus(_ type: Int) -> [Double]? {
        
        switch type {
        case let t where fighterTypes.contains(t): return fighterBonus
        case let t where bomberTypes.contains(t): return bomberBonus
        case let t where attackerTypes.contains(t): return attackerBonus
        case let t where floatplaneBomberTypes.contains(t): return floatplaneBomberBonus
        case let t where floatplaneFighterTypes.contains(t): return floatplaneFighterBonus
        case let t where jetBomberTypes.contains(t): return jetBomberBonus
        default: return nil
        }
    }
    
    private enum SlotState {
        
        case valid(SlotItem, Int, Int)
        
        case invalid
    }
    
    private func slotState(at index: Int) -> SlotState {
        
        let itemCount = ship.slotItemCount(index)
        if itemCount == 0 { return .invalid }
        guard let item = slotItem(at: index) else { return .invalid }
        
        return .valid(item, itemCount, item.master_slotItem.type_2)
    }
    
    private func slotSeiku(at index: Int) -> Double {
        
        guard case let .valid(item, itemCount, type2) = slotState(at: index),
            seikuEffectiveTypes.contains(type2) else {
                
                return 0
        }
        
        let taiku = Double(item.master_slotItem.tyku)
        let lv = Double(item.level)
        let rate = bomberTypes.contains(type2) ? 0.25 : 0.2
        
        return (taiku + lv * rate) * sqrt(Double(itemCount))
    }
    
    private func skilledSlotSeiku(at index: Int) -> Double {
        
        guard case let .valid(item, _, type2) = slotState(at: index),
            let typeBonus = typeBonus(type2) else {
                
                return 0
        }
        
        let airLevel = item.alv
        
        return typeBonus[airLevel] + skillBonus[airLevel]
    }
    
    private func seiku(at index: Int) -> Int {
        
        return Int(slotSeiku(at: index) + skilledSlotSeiku(at: index))
    }
    
}
