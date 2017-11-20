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
    
    case first
    case second
    case each
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
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcHougeki2()
        calcHougeki3()
        calcRaigeki()
    }
    
    func calcCombinedBattleAir() {
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcRaigeki()
        calcHougeki2()
        calcHougeki3()
    }
    
    func calcEachBattleAir() {
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcHougeki2()
        calcRaigeki()
        calcHougeki3()
    }
    
    func calcEnemyCombinedBattle() {
        
        // same phase as combined air
        calcCombinedBattleAir()
    }
    
    func calcMidnight() {
        
        calculateMidnightBattle()
    }
}

// MARK: - Battle phase
extension DamageCalculator {
    
    private func calcKouku() {
        
        calculateFDam(baseKeyPath: "api_data.api_kouku.api_stage3")
        calculateFDam(baseKeyPath: "api_data.api_kouku2.api_stage3")
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２　全体 use kouku nor kouku2
        // 連合vs連合（機動）　第１　全体 use kouku nor kouku2
        let bf: () -> BattleFleet = {
            
            switch self.battleType {
            case .combinedWater, .combinedAir,
                 .eachCombinedWater, .eachCombinedAir:
                return .second
                
            default: return .first
            }
        }
        calculateFDam(baseKeyPath: "api_data.api_kouku.api_stage3_combined", bf)
        calculateFDam(baseKeyPath: "api_data.api_kouku2.api_stage3_combined", bf)
        
    }
    
    private func calcOpeningAttack() {
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２　全体
        // 連合vs連合（機動）　第２　全体
        calculateFDam(baseKeyPath: "api_data.api_opening_atack") {
            
            switch battleType {
            case .combinedWater, .combinedAir: return .second
                
            case .eachCombinedWater, .eachCombinedAir: return .each
                
            default: return .first
            }
        }
    }
    
    private func calcOpeningTaisen() {
        
        calculateHogeki(baseKeyPath: "api_data.api_opening_taisen") {
            
            isCombinedBattle ? .second : .first
        }
    }
    
    private func calcHougeki1() {
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第１
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第１
        // 連合vs連合（機動）　第１
        calculateHogeki(baseKeyPath: "api_data.api_hougeki1") {
            
            switch battleType {
            case .combinedAir: return .second
                
            default: return .first
            }
        }
    }
    
    private func calcHougeki2() {
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第１
        // 連合vs通常（機動）　第１
        // 連合vs連合（水上）　第１　全体
        // 連合vs連合（機動）　第２
        calculateHogeki(baseKeyPath: "api_data.api_hougeki2") {
            
            switch battleType {
            case .eachCombinedWater: return .each
                
            case .eachCombinedAir: return .each
                
            default: return .first
            }
        }
    }
    
    private func calcHougeki3() {
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第１
        // 連合vs連合（水上）　第２
        // 連合vs連合（機動）　第１　全体
        calculateHogeki(baseKeyPath: "api_data.api_hougeki3") {
            
            switch battleType {
            case .combinedWater: return .second
                
//            case .eachCombinedWater: return .second  // 1~12
            case .eachCombinedAir: return .each
                
            default: return .first
            }
        }
    }
    
    private func calcRaigeki() {
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２　全体
        // 連合vs連合（機動）　第２　全体
        calculateFDam(baseKeyPath: "api_data.api_raigeki") {
            
            switch battleType {
            case .combinedWater, .combinedAir: return .second
                
            case .eachCombinedWater, .eachCombinedAir: return .each
                
            default: return .first
            }
        }
    }
    
    private func calculateMidnightBattle() {
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２
        // 連合vs連合（機動）　第２
        calculateHogeki(baseKeyPath: "api_data.api_hougeki") {
            
            isCombinedBattle ? .second : .first
        }
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
    
    private func buildDamagesOfFleet(fleet: Int, ships: [Ship]) {
        
        guard case 0...1 = fleet else { return Logger.shared.log("fleet must 0 or 1.") }
        guard let battle = store.battle() else { return Logger.shared.log("Battle is invalid.") }
        
        zip(ships, (0...)).forEach { ship, index in
            
            guard let damage = store.createDamage() else { return Logger.shared.log("Can not create Damage") }
            
            damage.battle = battle
            damage.hp = ship.nowhp
            damage.shipID = ship.id
            damage.id = index
        }
    }
    
    private func buildDamagedEntity() {
        
        guard let battle = store.battle() else { return Logger.shared.log("Battle is invalid.") }
        
        // 第一艦隊
        let firstFleetShips = ServerDataStore.default.ships(byDeckId: battle.deckId)
        buildDamagesOfFleet(fleet: 0, ships: firstFleetShips)
        
        // 第二艦隊
        if isCombinedBattle {
            
            let secondFleetShips = ServerDataStore.default.ships(byDeckId: 2)
            buildDamagesOfFleet(fleet: 1, ships: secondFleetShips)
        }
    }
}

// MARK: - Primitive Calclator
extension DamageCalculator {
    
    private func hogekiTargets(_ list: JSON) -> [[Int]]? {
        
        guard let targetArraysArray = list
            .array?
            .flatMap({ $0.array?.flatMap { $0.int } }) else {
                
                return nil
        }
        
        guard list.count == targetArraysArray.count else {
            
            return Logger.shared.log("api_df_list is wrong", value: nil)
        }
        
        return targetArraysArray
    }
    
    private func hogekiDamages(_ list: JSON) -> [[Int]]? {
        
        return list.array?.flatMap { $0.array?.flatMap { $0.int } }
    }
    
    private func enemyFlags(_ list: JSON) -> [Int]? {
        
        return list.array?.flatMap { $0.int }
    }
    
    private func validTargetPos(_ targetPos: Int, in battleFleet: BattleFleet) -> Bool {
        
        return 0..<damages.count ~= targetPos
    }
    
    private func firstFleetShipsCount() -> Int {
        
        return store.battle()?.firstFleetShipsCount ?? 6
    }
    
    private func position(_ pos: Int, in fleet: BattleFleet) -> Int? {
        
        let shipOffset = (fleet == .second) ? firstFleetShipsCount() : 0
        
        let damagePos = pos + shipOffset
        
        guard case 0..<damages.count = damagePos else { return nil }
        
        return damagePos
    }
    
    private func calcHP(damage: Damage, receive: Int) {
        
        damage.hp -= receive
        
        if damage.hp > 0 { return }
        
        guard let ship = ServerDataStore.default.ship(by: damage.shipID) else { return }
        
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
    
    private func calculateHogeki(baseKeyPath: String, battleFleet: BattleFleet = .first) {
        
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        
        guard let targetPosLists = hogekiTargets(baseValue["api_df_list"]),
            let damageLists = hogekiDamages(baseValue["api_damage"]) else {
                
                Debug.print("Cound not find api_df_list or api_damage for \(baseKeyPath)", level: .full)
                return
        }
        
        guard targetPosLists.count == damageLists.count else { return Logger.shared.log("api_damage is wrong.") }
        
        Debug.print("Start Hougeki \(baseKeyPath)", level: .debug)
        
        let enemyOmitedDamages = omitEnemyDamage(targetPosLists: targetPosLists,
                                                 damageLists: damageLists,
                                                 eFlags: enemyFlags(baseValue["api_at_eflag"]))
        
        enemyOmitedDamages.forEach { (targetPosList, damageList) in
            
            zip(targetPosList, damageList).forEach { (targetPos, damage) in
                
                guard validTargetPos(targetPos, in: battleFleet) else { return Logger.shared.log("invalid position \(targetPos)") }
                
                guard let damagePos = position(targetPos, in: battleFleet) else {
                    
                    return Logger.shared.log("damage pos is larger than damage count")
                }
                
                calcHP(damage: damages[damagePos], receive: damage)
                
                Debug.excute(level: .debug) {
                    
                    let shipOffset = (battleFleet == .second) ? firstFleetShipsCount() : 0
                    print("Hougeki \(targetPos + shipOffset) -> \(damage)")
                }
            }
        }
    }
    
    private func calculateFDam(baseKeyPath: String, _ bf: () -> BattleFleet) {
        
        calculateFDam(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    
    private func calculateFDam(baseKeyPath: String, battleFleet: BattleFleet = .first) {
        
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        
        guard let fdamArray = baseValue["api_fdam"].arrayObject else {

            Debug.print("Could not find api_fdam of \(baseKeyPath)", level: .full)
            
            return
        }
        
        guard let IntFdamArray = fdamArray as? [IntConvertable] else {
            
            Debug.print("api_fdam value of \(baseKeyPath) is not [Int].", level: .debug)
            Debug.print(baseValue, level: .debug)
            
            return
        }
        let frendDamages = IntFdamArray.map { $0.toInt() }
        
        Debug.print("Start FDam \(baseKeyPath)", level: .debug)
        
        frendDamages.enumerated().forEach { (idx, damage) in
            
            guard let damagePos = position(idx, in: battleFleet) else { return }
            
            calcHP(damage: damages[damagePos], receive: damage)
            
            Debug.excute(level: .debug) {
                
                let shipOffset = (battleFleet == .second) ? firstFleetShipsCount() : 0
                print("FDam \(idx + shipOffset) -> \(damage)")
            }
        }
    }
}

// MARK: - Damage control
extension DamageCalculator {
    
    private func damageControlIfPossible(ship: Ship) -> Int {
        
        let store = ServerDataStore.default
        
        let damageControl = ship
            .equippedItem
            .lazy
            .flatMap { $0 as? SlotItem }
            .map { store.masterSlotItemID(by: $0.id) }
            .flatMap { DamageControlID(rawValue: $0) }
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
