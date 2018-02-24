//
//  CalculateDamageCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/15.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

enum BattleType {
    
    case normal
    case combinedAir
    case combinedWater
    case eachCombinedAir
    case eachCombinedWater
    case enemyCombined
}

enum DamageControlID: Int {
    
    case damageControl = 42
    case goddes = 43
}

final class CalculateDamageCommand: JSONCommand {
    
    override func execute() {
        
        switch api.endpoint {
            
        case .battle, .airBattle, .ldAirBattle:
            normalBattle(battleType: .normal)
            
        case .combinedEcBattle:
            enemyCombinedBattle(battleType: .enemyCombined)
            
        case .combinedBattle, .combinedAirBattle:
            combinedAirBattle(battleType: .combinedAir)
            
        case .combinedBattleWater, .combinedLdAirBattle:
            normalBattle(battleType: .combinedWater)
            
        case .combinedEachBattle:
            eachAirBattle(battleType: .eachCombinedAir)
            
        case .combinedEachBattleWater:
            normalBattle(battleType: .eachCombinedWater)
            
        case .combinedEachNightToDay:
            eachNightToDayBattle(battleType: .normal)
            
        case .midnightBattle, .midnightSpMidnight:
            midnightBattle(battleType: .normal)
            
        case .combinedMidnightBattle, .combinedSpMidnight:
            midnightBattle(battleType: .combinedAir)
            
        case .combinedEcMidnightBattle:
            midnightBattle(battleType: .eachCombinedAir)
            
        case .battleResult, .combinedBattleResult:
            applyDamage()
            resetDamage()
            
        default: return Logger.shared.log("Missing API: \(apiResponse.api)")
        }
    }
    
    func normalBattle(battleType: BattleType) {
        
        updateBattleCell()
        DamageCalculator(json, battleType).calculateBattle()
    }
    
    func combinedAirBattle(battleType: BattleType) {
        
        updateBattleCell()
        DamageCalculator(json, battleType).calcCombinedBattleAir()
    }
    
    func eachAirBattle(battleType: BattleType) {
        
        updateBattleCell()
        DamageCalculator(json, battleType).calcEachBattleAir()
    }
    
    func eachNightToDayBattle(battleType: BattleType) {
        
        updateBattleCell()
        DamageCalculator(json, battleType).calcEachNightToDay()
    }
    
    func enemyCombinedBattle(battleType: BattleType) {
        
        updateBattleCell()
        DamageCalculator(json, battleType).calcEnemyCombinedBattle()
    }
    
    func midnightBattle(battleType: BattleType) {
        
        DamageCalculator(json, battleType).calcMidnight()
    }
}

extension CalculateDamageCommand {
    
    func resetDamage() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        store.sync { store.damages().forEach(store.delete) }
    }
    
    func applyDamage() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        let totalDamages = store.sync { store.sortedDamagesById() }
        
        let aStore = ServerDataStore.default
        
        Debug.excute(level: .debug) {
            
            print("-------")
            
            store.sync {
                totalDamages.forEach { damage in
                    
                    let shipId = damage.shipID
                    guard let ship = aStore.sync(execute: { aStore.ship(by: shipId) }) else { return }
                    
                    let damagedHp = damage.hp
                    aStore.sync {
                        if ship.nowhp != damagedHp {
                            
                            print("\(ship.name)(\(ship.id)),HP \(ship.nowhp) -> \(damagedHp)")
                        }
                    }
                }
            }
            
            print("------- End Battle")
        }
        
        // 第二艦隊単独出撃で正しくデータが反映されるように逆順にして計算
        store.sync {
            totalDamages.reversed().forEach { damage in
                
                let shipId = damage.shipID
                guard let ship = aStore.sync(execute: { aStore.ship(by: shipId) }) else { return }
                
                let damagedHp = damage.hp
                aStore.sync { ship.nowhp = damagedHp }
                
                if damage.useDamageControl { self.removeFirstDamageControl(of: shipId) }
            }
        }
    }
    
    func updateBattleCell() {
        
        let store = TemporaryDataStore.default
        
        guard let battle = store.sync(execute: { store.battle() }) else {
            
            return Logger.shared.log("Battle is invalid.")
        }
        
        store.sync { battle.battleCell = (battle.no == 0 ? nil : battle.no as NSNumber) }
        
        Debug.excute(level: .debug) {
            
            print("Enter Cell ------- ")
            
            if let seiku = json["api_data"]["api_kouku"]["api_stage1"]["api_disp_seiku"].int {
                
                switch seiku {
                case 0: print("制空権 均衡")
                case 1: print("制空権 確保")
                case 2: print("制空権 優勢")
                case 3: print("制空権 劣勢")
                case 4: print("制空権 喪失")
                default: break
                }
            }
            
            if let intercept = json["api_data"]["api_formation"][2].int {
                
                switch intercept {
                case 1: print("交戦形態 同航戦")
                case 2: print("交戦形態 反航戦")
                case 3: print("交戦形態 Ｔ字戦有利")
                case 4: print("交戦形態 Ｔ字戦不利")
                default: break
                }
            }
        }
    }
    
    func removeFirstDamageControl(of shipId: Int) {
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync {
            
            guard let ship = store.ship(by: shipId) else { return }
            
            let (item, damageControl) = ship
                .equippedItem
                .lazy
                .flatMap { $0 as? SlotItem }
                .map { ($0, store.masterSlotItemID(by: $0.id)) }
                .map { ($0.0, DamageControlID(rawValue: $0.1)) }
                .filter { $0.1 != nil }
                .first ?? (nil, nil)
            
            if let validDamageControl = damageControl {
                
                switch validDamageControl {
                case .damageControl: break
                    
                case .goddes:
                    ship.fuel = ship.maxFuel
                    ship.bull = ship.maxBull
                }
                
                guard let equiped = ship.equippedItem.array as? [SlotItem] else { return }
                
                ship.equippedItem = NSOrderedSet(array: equiped.filter { $0 != item })
                
                return
            }
            
            // check extra slot
            let exItemId = store.sync { store.masterSlotItemID(by: ship.slot_ex) }
            
            guard let exType = DamageControlID(rawValue: exItemId) else { return }
            
            switch exType {
            case .damageControl: break
                
            case .goddes:
                ship.fuel = ship.maxFuel
                ship.bull = ship.maxBull
            }
            
            ship.slot_ex = -1
        }
    }
}
