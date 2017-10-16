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
        
        if array.count != 12 {
            
            buildDamagedEntity()
            
            let newDamages = store.sortedDamagesById()
            
            guard newDamages.count == 12 else {
                
                print("ERROR!!!! CAN NOT CREATE DAMAGE OBJECT")
                return []
            }
            
            return newDamages
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
        
        guard case 0...1 = fleet else { return print("fleet must 0 or 1.") }
        guard let battle = store.battle() else { return print("Battle is invalid.") }
        
        (0..<6).forEach {
            
            guard let damage = store.createDamage() else { return print("Can not create Damage") }
            
            damage.battle = battle
            damage.id = $0 + fleet * 6
            
            guard case 0..<ships.count = $0 else { return }
            
            damage.hp = ships[$0].nowhp
            damage.shipID = ships[$0].id
        }
    }
    
    private func buildDamagedEntity() {
        
        guard let battle = store.battle() else { return print("Battle is invalid.") }
        
        // 第一艦隊
        let firstFleetShips = ServerDataStore.default.ships(byDeckId: battle.deckId)
        buildDamagesOfFleet(fleet: 0, ships: firstFleetShips)
        
        // 第二艦隊
        let secondFleetShips = ServerDataStore.default.ships(byDeckId: 2)
        buildDamagesOfFleet(fleet: 1, ships: secondFleetShips)
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
        
        guard list.count - 1 == targetArraysArray.count else {
            
            print("api_df_list is wrong")
            return nil
        }
        
        return targetArraysArray
    }
    
    private func hogekiDamages(_ list: JSON) -> [[Int]]? {
        
        return list.array?.flatMap { $0.array?.flatMap { $0.int } }
    }
    
    private func enemyFlags(_ list: JSON) -> [Int]? {
        
        return list.array?.flatMap { $0.int }.filter { $0 != -1 }
    }
    
    private func isTargetFriend(eFlags: [Int]?, index: Int) -> Bool {
        
        if let eFlags = eFlags, 0..<eFlags.count ~= index {
            
            return eFlags[index] == 1
        }
        
        return true
    }
    
    private func validTargetPos(_ targetPos: Int, in battleFleet: BattleFleet) -> Bool {
        
        let upper = (battleFleet == .each ? 12 : 6)
        
        return 1...upper ~= targetPos
    }
    
    private func position(_ pos: Int, in fleet: BattleFleet) -> Int? {
        
        let shipOffset = (fleet == .second) ? 6 : 0
        
        let damagePos = pos - 1 + shipOffset
        
        guard case 0..<damages.count = damagePos else { return nil }
        
        return damagePos
    }
    
    private func calcHP(damage: Damage, receive: Int) {
        
        let hp = damage.hp as Int
        let newHP = hp - receive
        
        damage.hp = newHP
        
        if newHP > 0 { return }
        
        let shipId = damage.shipID
        
        guard let ship = ServerDataStore.default.ship(by: shipId) else { return }
        
        let efectiveHP = damageControlIfPossible(nowhp: newHP, ship: ship)
        if efectiveHP != 0, efectiveHP != newHP {
            
            damage.useDamageControl = true
        }
        
        damage.hp = efectiveHP
    }
    
    private func calculateHogeki(baseKeyPath: String, _ bf: () -> BattleFleet) {
        
        calculateHogeki(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    
    private func calculateHogeki(baseKeyPath: String, battleFleet: BattleFleet = .first) {
        
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        
        guard let targetPosLists = hogekiTargets(baseValue["api_df_list"]),
            let damageLists = hogekiDamages(baseValue["api_damage"]) else {
                
                Debug.print("Cound not find api_df_list or api_damage for \(baseKeyPath)", level: .full)
                return
        }
        
        guard targetPosLists.count == damageLists.count else { return print("api_damage is wrong.") }
        
        let eFlags = enemyFlags(baseValue["api_at_eflag"])
        
        Debug.print("Start Hougeki \(baseKeyPath)", level: .debug)
        
        zip(targetPosLists, damageLists).enumerated().forEach { (i, list) in
            
            if !isTargetFriend(eFlags: eFlags, index: i) {
                
                Debug.excute(level: .debug) {
                    
                    print("target is enemy")
                }
                
                return
            }
            
            zip(list.0, list.1).forEach { (targetPos, damage) in
                
                guard validTargetPos(targetPos, in: battleFleet) else { return }
                
                guard let damagePos = position(targetPos, in: battleFleet) else {
                    
                    print("damage pos is larger than damage count")
                    return
                }
                
                calcHP(damage: damages[damagePos], receive: damage)
                
                Debug.excute(level: .debug) {
                    
                    let shipOffset = (battleFleet == .second) ? 6 : 0
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
            
            if idx == 0 { return }
            
            guard let damagePos = position(idx, in: battleFleet) else { return }
            
            calcHP(damage: damages[damagePos], receive: damage)
            
            Debug.excute(level: .debug) {
                
                let shipOffset = (battleFleet == .second) ? 6 : 0
                print("FDam \(idx + shipOffset) -> \(damage)")
            }
        }
    }
}


// MARK: - Damage control
extension DamageCalculator {
    
    private func damageControlIfPossible(nowhp: Int, ship: Ship) -> Int {
        
        var nowHp = nowhp
        if nowHp < 0 { nowHp = 0 }
        let maxhp = ship.maxhp
        let store = ServerDataStore.default
        var useDamageControl = false
        
        ship.equippedItem.forEach {
            
            if useDamageControl { return }
            
            guard let master = $0 as? SlotItem else { return }
            
            let masterSlotItemId = store.masterSlotItemID(by: master.id)
            
            guard let type = DamageControlID(rawValue: masterSlotItemId) else { return }
            
            switch type {
            case .damageControl:
                nowHp = Int(Double(maxhp) * 0.2)
                useDamageControl = true
                
            case .goddes:
                nowHp = maxhp
                useDamageControl = true
            }
        }
        
        if useDamageControl { return nowHp }
        
        // check extra slot
        let exItemId = store.masterSlotItemID(by: ship.slot_ex)
        
        guard let exType = DamageControlID(rawValue: exItemId) else { return nowHp }
        
        switch exType {
        case .damageControl:
            nowHp = Int(Double(maxhp) * 0.2)
            
        case .goddes:
            nowHp = maxhp
        }
        
        return nowHp
    }
}
