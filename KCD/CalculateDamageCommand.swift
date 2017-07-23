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
enum BattleFleet {
    case first
    case second
    case each
}

class CalculateDamageCommand: JSONCommand {
    private let store = TemporaryDataStore.oneTimeEditor()
    
    var battleType: BattleType = .normal
    var damages: [Damage] {
        let array = store.sortedDamagesById()
        if array.count != 12 {
            buildDamagedEntity()
            let newDamages = store.sortedDamagesById()
            guard newDamages.count == 12
                else {
                    print("ERROR!!!! CAN NOT CREATE DAMAGE OBJECT")
                    return []
            }
            return newDamages
        }
        return array
    }
    var isCombinedBattle: Bool {
        switch battleType {
        case .combinedAir, .combinedWater, .eachCombinedAir, .eachCombinedWater:
            return true
        default:
            return false
        }
    }
    
    override func execute() {
        guard let battleApi = BattleAPI(rawValue: api)
            else { return }
        
        switch battleApi {
        case .battle, .airBattle, .ldAirBattle:
            calculateBattle()
        case .combinedEcBattle:
            battleType = .enemyCombined
            calcEnemyCombinedBattle()
        case .combinedBattle, .combinedAirBattle:
            battleType = .combinedAir
            calcCombinedBattleAir()
        case .combinedBattleWater, .combinedLdAirBattle:
            battleType = .combinedWater
            calculateBattle()
        case .combinedEachBattle:
            battleType = .eachCombinedAir
            calcEachBattleAir()
        case .combinedEachBattleWater:
            battleType = .eachCombinedWater
            calculateBattle()
        case .midnightBattle, .midnightSpMidnight:
            calcMidnight()
        case .combinedMidnightBattle, .combinedSpMidnight:
            battleType = .combinedAir
            calcMidnight()
        case .combinedEcMidnightBattle:
            battleType = .eachCombinedAir
            calcMidnight()
        case .battleResult, .combinedBattleResult:
            applyDamage()
            resetDamage()
        }
    }
    
    private func resetDamage() {
        store.damages().forEach { store.delete($0) }
    }
    private func applyDamage() {
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
    private func buildDamagedEntity() {
        guard let battle = store.battle()
            else { return print("Battle is invalid.") }
        
        let aStore = ServerDataStore.default
        var ships: [Any] = []
        
        // 第一艦隊
        let firstFleetShips = aStore.ships(byDeckId: battle.deckId)
        ships += (firstFleetShips as [Any])
        while ships.count != 6 {
            ships.append(0)
        }
        
        // 第二艦隊
        let secondFleetShips = aStore.ships(byDeckId: 2)
        ships += (secondFleetShips as [Any])
        while ships.count != 12 {
            ships.append(0)
        }
        ships.enumerated().forEach {
            guard let damage = store.createDamage()
                else { return print("Can not create Damage") }
            damage.battle = battle
            damage.id = $0.offset
            if let ship = $0.element as? Ship {
                damage.hp = ship.nowhp
                damage.shipID = ship.id
            }
        }
    }
    
    func updateBattleCell() {
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
}
