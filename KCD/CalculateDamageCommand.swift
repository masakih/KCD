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
        
        guard let battleApi = BattleAPI(rawValue: api)
            else { return }
        
        switch battleApi {
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
            
        case .midnightBattle, .midnightSpMidnight:
            midnightBattle(battleType: .normal)
            
        case .combinedMidnightBattle, .combinedSpMidnight:
            midnightBattle(battleType: .combinedAir)
            
        case .combinedEcMidnightBattle:
            midnightBattle(battleType: .eachCombinedAir)
            
        case .battleResult, .combinedBattleResult:
            applyDamage()
            resetDamage()
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
        
        store.damages().forEach { store.delete($0) }
    }
    
    func applyDamage() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        let totalDamages = store.sortedDamagesById()
        
        guard totalDamages.count == 12
            else { return print("Damages count is invalid. count is \(totalDamages.count).") }
        
        let aStore = ServerDataStore.oneTimeEditor()
        
        totalDamages.forEach {
            
            guard let ship = aStore.ship(by: $0.shipID)
                else { return }
            
            if ship.nowhp != $0.hp {
                
                Debug.print("\(ship.name)(\(ship.id)),HP \(ship.nowhp) -> \($0.hp)", level: .debug)
            }
            
            ship.nowhp = $0.hp
            
            if $0.useDamageControl { removeFirstDamageControl(of: ship) }
        }
        
        Debug.print("------- End Battle", level: .debug)
    }
    
    func updateBattleCell() {
        
        let store = TemporaryDataStore.default
        
        guard let battle = store.battle()
            else { return print("Battle is invalid.") }
        
        battle.battleCell = (battle.no == 0 ? nil : battle.no as NSNumber)
        
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
    
    func removeFirstDamageControl(of ship: Ship) {
        
        let equiped = ship.equippedItem
        let newEquiped = equiped.array
        let store = ServerDataStore.default
        var useDamageControl = false
        
        equiped.forEach {
            
            if useDamageControl { return }
            
            guard let master = $0 as? SlotItem
                else { return }
            
            let masterSlotItemId = store.masterSlotItemID(by: master.id)
            
            guard let type = DamageControlID(rawValue: masterSlotItemId)
                else { return }
            
            switch type {
            case .goddes:
                ship.fuel = ship.maxFuel
                ship.bull = ship.maxBull
                fallthrough
                
            case .damageControl:
                if var equiped = newEquiped as? [SlotItem],
                    let index = equiped.index(of: master) {
                    
                    equiped[index...index] = []
                    ship.equippedItem = NSOrderedSet(array: equiped)
                    useDamageControl = true
                }
            }
        }
        
        if useDamageControl { return }
        
        // check extra slot
        let exItemId = store.masterSlotItemID(by: ship.slot_ex)
        
        guard let exType = DamageControlID(rawValue: exItemId)
            else { return }
        
        switch exType {
        case .goddes:
            ship.fuel = ship.maxFuel
            ship.bull = ship.maxBull
            fallthrough
            
        case .damageControl:
            ship.slot_ex = -1
        }
    }
}
