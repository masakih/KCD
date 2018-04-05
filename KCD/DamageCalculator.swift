//
//  DamageCalculator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/07/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

enum BattleFleet {
    
    case normal
    case secondOnly
}

final class DamageCalculator {
    
    private let store = TemporaryDataStore.oneTimeEditor()
    
    private let json: JSON
    private let battleType: BattleType
    
    init(_ json: JSON, _ battleType: BattleType = .normal) {
        
        self.battleType = battleType
        self.json = json
    }
}

// MARK: - Battle type
extension DamageCalculator {
    
    func calculateBattle() {
        
        store.sync {
            
            self.calcKouku()
            self.calcOpeningTaisen()
            self.calcOpeningAttack()
            self.calcHougeki1()
            self.calcHougeki2()
            self.calcHougeki3()
            self.calcRaigeki()
        }
    }
    
    func calcCombinedBattleAir() {
        
        store.sync {
            
            self.calcKouku()
            self.calcOpeningTaisen()
            self.calcOpeningAttack()
            self.calcHougeki1()
            self.calcRaigeki()
            self.calcHougeki2()
            self.calcHougeki3()
        }
    }
    
    func calcEachBattleAir() {
        
        store.sync {
            
            self.calcKouku()
            self.calcOpeningTaisen()
            self.calcOpeningAttack()
            self.calcHougeki1()
            self.calcHougeki2()
            self.calcRaigeki()
            self.calcHougeki3()
        }
    }
    
    func calcEachNightToDay() {
        
        store.sync {
            
            self.calcNightHogeki1()
            self.calcNightHogeki2()
            self.calcKouku()
            self.calcOpeningTaisen()
            self.calcOpeningAttack()
            self.calcHougeki1()
            self.calcHougeki2()
            self.calcRaigeki()
            self.calcHougeki3()
        }
    }
    
    func calcEnemyCombinedBattle() {
        
        // same phase as combined air
        calcCombinedBattleAir()
    }
    
    func calcMidnight() {
        
        store.sync {
            
            self.calculateMidnightBattle()
        }
    }
}

// MARK: - Battle phase
extension DamageCalculator {
    
    private func calcKouku() {
        
        calculateFDam(baseKeyPath: "api_data.api_kouku.api_stage3")
        calculateFDam(baseKeyPath: "api_data.api_kouku2.api_stage3")
        
        let bf: () -> BattleFleet = {
            
            switch self.battleType {
            case .combinedWater,
                 .combinedAir,
                 .eachCombinedWater,
                 .eachCombinedAir:
                return .secondOnly
                
            default: return .normal
            }
        }
        calculateFDam(baseKeyPath: "api_data.api_kouku.api_stage3_combined", bf)
        calculateFDam(baseKeyPath: "api_data.api_kouku2.api_stage3_combined", bf)
        
    }
    
    private func calcOpeningAttack() {
        
        calculateFDam(baseKeyPath: "api_data.api_opening_atack")
    }
    
    private func calcOpeningTaisen() {
        
        calculateHogeki(baseKeyPath: "api_data.api_opening_taisen")
    }
    
    private func calcHougeki1() {
        
        calculateHogeki(baseKeyPath: "api_data.api_hougeki1")
    }
    
    private func calcHougeki2() {
        
        calculateHogeki(baseKeyPath: "api_data.api_hougeki2")
    }
    
    private func calcHougeki3() {
        
        calculateHogeki(baseKeyPath: "api_data.api_hougeki3")
    }
    
    private func calcNightHogeki1() {
        
        calculateHogeki(baseKeyPath: "api_data.api_n_hougeki1")
    }
    
    private func calcNightHogeki2() {
        
        calculateHogeki(baseKeyPath: "api_data.api_n_hougeki2")
    }
    
    private func calcRaigeki() {
        
        calculateFDam(baseKeyPath: "api_data.api_raigeki")
    }
    
    private func calculateMidnightBattle() {
        
        calculateHogeki(baseKeyPath: "api_data.api_hougeki")
    }
}

// MARK: - Properties
extension DamageCalculator {
    
    private var damages: [Damage] {
        
        let array = store.sortedDamagesById()
        
        if array.isEmpty {
            
            buildDamagedEntity()
            
            return store.sortedDamagesById()
        }
        
        return array
    }
    
    private var isCombinedBattle: Bool {
        
        switch battleType {
        case .combinedAir, .combinedWater, .eachCombinedAir, .eachCombinedWater:
            return true
            
        default:
            return false
        }
    }
    
    private func makeDamage(num: Int) -> [Damage] {
        
        guard let battle = store.battle() else { return Logger.shared.log("Battle is invalid.", value: []) }
        
        return (0..<num).compactMap {
            
            guard let damage = store.createDamage() else { return Logger.shared.log("Can not create Damage", value: nil) }
            
            damage.battle = battle
            damage.id = $0
            
            return damage
        }
    }
    
    private func buildDamages(first: [Ship], second: [Ship]?) {
        
        guard let battle = store.battle() else { return Logger.shared.log("Battle is invalid.") }
        
        let damages = makeDamage(num: 12)
        
        func setShip(_ ship: Ship, into damage: Damage) {
            
            let sStore = ServerDataStore.default
            
            damage.shipID = sStore.sync { ship.id }
            damage.hp = sStore.sync { ship.nowhp }
            
            Debug.excute(level: .debug) {
                let name = sStore.sync { ship.name }
                print("add Damage entity of \(name) at \(damage.id)")
            }
        }
        
        zip(first, damages).forEach(setShip)

        if let second = second {

            let secondsDamage = damages[6...]
            zip(second, secondsDamage).forEach(setShip)
        }
        
    }
    
    private func buildDamagedEntity() {
        
        guard let battle = store.battle() else { return Logger.shared.log("Battle is invalid.") }
        
        let sStore = ServerDataStore.default
        // 第一艦隊
        let deckId = battle.deckId
        let firstFleetShips = sStore.sync { sStore.ships(byDeckId: deckId) }
        
        // 第二艦隊
        if isCombinedBattle {
            
            let secondFleetShips = sStore.sync { sStore.ships(byDeckId: 2) }
            buildDamages(first: firstFleetShips, second: secondFleetShips)
        } else {
            
            buildDamages(first: firstFleetShips, second: nil)
        }
    }
}

// MARK: - Primitive Calclator
extension DamageCalculator {
    
    private func hogekiTargets(_ list: JSON) -> [[Int]]? {
        
        guard let targetArraysArray = list
            .array?
            .compactMap({ $0.array?.compactMap { $0.int } }) else {
                
                return nil
        }
        
        guard list.count == targetArraysArray.count else {
            
            return Logger.shared.log("api_df_list is wrong", value: nil)
        }
        
        return targetArraysArray
    }
    
    private func hogekiDamages(_ list: JSON) -> [[Int]]? {
        
        return list.array?.compactMap { $0.array?.compactMap { $0.int } }
    }
    
    private func enemyFlags(_ list: JSON) -> [Int]? {
        
        return list.array?.compactMap { $0.int }
    }
    
    private func validTargetPos(_ targetPos: Int, in battleFleet: BattleFleet) -> Bool {
        
        return 0..<damages.count ~= targetPos
    }
    
    private func position(_ pos: Int, in fleet: BattleFleet) -> Int? {
        
        let damagePos = (fleet == .secondOnly ? pos + 6 : pos)
        
        guard case 0..<damages.count = damagePos else { return nil }
        
        return damagePos
    }
    
    private func calcHP(damage: Damage, receive: Int) {
        
        Debug.excute(level: .debug) {
            
            let store = ServerDataStore.default
            if receive != 0, let shipName = store.sync(execute: { store.ship(by: damage.shipID)?.name }) {
                
                print("\(shipName) recieve Damage \(receive)")
            }
        }
        
        damage.hp -= receive
        
        if damage.hp > 0 { return }
        
        let sStore = ServerDataStore.default
        guard let ship = sStore.sync(execute: { sStore.ship(by: damage.shipID) }) else { return }
        
        damage.hp = damageControlIfPossible(ship: ship)
        damage.useDamageControl = (damage.hp != 0)
        
    }
    
    private func calculateHogeki(baseKeyPath: String, _ bf: () -> BattleFleet) {
        
        calculateHogeki(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    
    private func omitEnemyDamage(targetPosLists: [[Int]], damageLists: [[Int]], eFlags: [Int]?) -> [([Int], [Int])] {
        
        guard let eFlags = eFlags else { return zip(targetPosLists, damageLists).map { $0 } }
        
        return zip(zip(targetPosLists, damageLists), eFlags).filter { $0.1 == 1 }.map { $0.0 }
    }
    
    private func calculateHogeki(baseKeyPath: String, battleFleet: BattleFleet = .normal) {
        
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        
        guard let targetPosLists = hogekiTargets(baseValue["api_df_list"]),
            let damageLists = hogekiDamages(baseValue["api_damage"]) else {
                
                Debug.print("Cound not find api_df_list or api_damage for \(baseKeyPath)", level: .full)
                return
        }
        
        guard targetPosLists.count == damageLists.count else { return Logger.shared.log("api_damage is wrong.") }
        
        Debug.print("Start Hougeki \(baseKeyPath)", level: .debug)
        
        omitEnemyDamage(targetPosLists: targetPosLists, damageLists: damageLists, eFlags: enemyFlags(baseValue["api_at_eflag"]))
            .map { (targetPosList, damageList) -> (Int, Int) in
                
                guard let pos = targetPosList.first else { return (0, 0) }
                
                return (pos, damageList.filter { $0 > 0 }.reduce(0, +))
            }
            .forEach { (targetPos, damage) in
                
                guard validTargetPos(targetPos, in: battleFleet) else { return Logger.shared.log("invalid position \(targetPos)") }
                
                guard let damagePos = position(targetPos, in: battleFleet) else {
                    
                    return Logger.shared.log("damage pos is larger than damage count")
                }
                
                calcHP(damage: damages[damagePos], receive: damage)
                
                Debug.print("Hougeki \(targetPos) -> \(damage)", level: .debug)
        }
    }
    
    private func calculateFDam(baseKeyPath: String, _ bf: () -> BattleFleet) {
        
        calculateFDam(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    
    private func calculateFDam(baseKeyPath: String, battleFleet: BattleFleet = .normal) {
        
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        
        guard let fdamArray = baseValue["api_fdam"].arrayObject else {

            Debug.print("Could not find api_fdam of \(baseKeyPath)", level: .full)
            
            return
        }
        
        guard let intFdamArray = fdamArray as? [IntConvertable] else {
            
            Debug.print("api_fdam value of \(baseKeyPath) is not [Int].", level: .debug)
            Debug.print(baseValue, level: .debug)
            
            return
        }
        let frendDamages = intFdamArray.map { $0.toInt() }
        
        Debug.print("Start FDam \(baseKeyPath)", level: .debug)
        
        frendDamages.enumerated().forEach { (idx, damage) in
            
            guard let damagePos = position(idx, in: battleFleet) else { return }
            
            calcHP(damage: damages[damagePos], receive: damage)
            
            Debug.print("FDam \(idx) -> \(damage)", level: .debug)
        }
    }
}

// MARK: - Damage control
extension DamageCalculator {
    
    private func damageControlIfPossible(ship: Ship) -> Int {
        
        let store = ServerDataStore.default
        return store.sync {
            let damageControl = ship
                .equippedItem
                .array
                .lazy
                .compactMap { $0 as? SlotItem }
                .map { store.masterSlotItemID(by: $0.id) }
                .compactMap { DamageControlID(rawValue: $0) }
                .first
            
            if let validDamageControl = damageControl {
                
                switch validDamageControl {
                case .damageControl:
                    Debug.print("Damage Control", level: .debug)
                    return Int(Double(ship.maxhp) * 0.2)
                    
                case .goddes:
                    Debug.print("Goddes", level: .debug)
                    return ship.maxhp
                }
            }
            
            // check extra slot
            let exItemId = store.masterSlotItemID(by: ship.slot_ex)
            
            guard let exType = DamageControlID(rawValue: exItemId) else { return 0 }
            
            switch exType {
            case .damageControl:
                Debug.print("Damage Control", level: .debug)
                return Int(Double(ship.maxhp) * 0.2)
                
            case .goddes:
                Debug.print("Goddes", level: .debug)
                return ship.maxhp
            }
        }
    }
}
