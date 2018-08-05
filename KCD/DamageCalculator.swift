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

private struct PositionedDamage {
    
    let position: Int
    let damage: Int
    
    static let zero = PositionedDamage(position: 0, damage: 0)
}

extension PositionedDamage: Equatable {
    
    static func == (lhs: PositionedDamage, rhs: PositionedDamage) -> Bool {
        
        return lhs.position == rhs.position && lhs.damage == rhs.damage
    }
}

private struct HogekiBattleData {
    
    let targetPositionList: [Int]
    let damageList: [Int]
    let enemyFlags: Bool
}

private func friendDamage(_ data: HogekiBattleData) -> PositionedDamage {
    
    guard !data.enemyFlags else { return .zero }
    
    guard let pos = data.targetPositionList.first else { return .zero }
    
    return PositionedDamage(position: pos,
                            damage: data.damageList.filter({ $0 > 0 }).reduce(0, +))
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
                
            default:
                
                return .normal
                
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
        
        guard let battle = store.battle() else {
            
            Logger.shared.log("Battle is invalid.")
            
            return []
        }
        
        return (0..<num).compactMap {
            
            guard let damage = store.createDamage() else {
                
                Logger.shared.log("Can not create Damage")
                
                return nil
            }
            
            damage.battle = battle
            damage.id = $0
            
            return damage
        }
    }
    
    private func buildDamages(first: [Ship], second: [Ship]?) {
        
        guard let battle = store.battle() else {
            
            Logger.shared.log("Battle is invalid.")
            
            return
        }
        
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
        
        guard let battle = store.battle() else {
            
            Logger.shared.log("Battle is invalid.")
            
            return
        }
        
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
            
            Logger.shared.log("api_df_list is wrong")
            
            return nil
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
        
        guard case 0..<damages.count = damagePos else {
            
            return nil
        }
        
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
        
        if damage.hp > 0 {
            
            return
        }
        
        let sStore = ServerDataStore.default
        guard let ship = sStore.sync(execute: { sStore.ship(by: damage.shipID) }) else {
            
            return
        }
        
        damage.hp = damageControlIfPossible(ship: ship)
        damage.useDamageControl = (damage.hp != 0)
        
    }
    
    private func calculateHogeki(baseKeyPath: String, _ bf: () -> BattleFleet) {
        
        calculateHogeki(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    
    private func buildBattleData(baseKeyPath: String) -> [HogekiBattleData] {
        
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        
        guard let targetPosLists = hogekiTargets(baseValue["api_df_list"]),
            let damageLists = hogekiDamages(baseValue["api_damage"]) else {
                
                Debug.print("Cound not find api_df_list or api_damage for \(baseKeyPath)", level: .full)
                
                return []
        }
        
        guard targetPosLists.count == damageLists.count else {
            
            Logger.shared.log("api_damage is wrong.")
            
            return []
        }
        
        guard let eFlags = enemyFlags(baseValue["api_at_eflag"]) else {
            
            return zip(targetPosLists, damageLists).map { HogekiBattleData(targetPositionList: $0.0, damageList: $0.1, enemyFlags: false) }
        }
        
        return zip(zip(targetPosLists, damageLists), eFlags)
            .map { arg -> HogekiBattleData in
                
                let ((targetPosList, damageList), eflag) = arg
                
                return HogekiBattleData(targetPositionList: targetPosList, damageList: damageList, enemyFlags: eflag != 1)
        }
    }
    
    private func calculateHogeki(baseKeyPath: String, battleFleet: BattleFleet = .normal) {
        
        Debug.print("Start Hougeki \(baseKeyPath)", level: .debug)
        
        buildBattleData(baseKeyPath: baseKeyPath)
            .map(friendDamage)
            .filter { $0 != .zero }
            .forEach { posDamage in
                
                guard validTargetPos(posDamage.position, in: battleFleet) else {
                    
                    Logger.shared.log("invalid position \(posDamage.position)")
                    
                    return
                }
                
                guard let damagePos = position(posDamage.position, in: battleFleet) else {
                    
                    Logger.shared.log("damage pos is larger than damage count")
                    
                    return
                }
                
                calcHP(damage: damages[damagePos], receive: posDamage.damage)
                
                Debug.print("Hougeki \(posDamage.position) -> \(posDamage.damage)", level: .debug)
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
            
            guard let damagePos = position(idx, in: battleFleet) else {
                
                return
            }
            
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
            
            guard let exType = DamageControlID(rawValue: exItemId) else {
                
                return 0
            }
            
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
